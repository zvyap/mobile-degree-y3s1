-- ============================================================================
-- BIKE REPORT PHOTO STORAGE
-- ============================================================================

-- Private bucket for bike report photos.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'bike-report-photos',
  'bike-report-photos',
  false,
  5242880, -- 5 MB
  array['image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;


-- ============================================================================
-- REMOVE OLD POLICIES IF THEY EXIST
-- ============================================================================

drop policy if exists "bike_report_photos_select"
on storage.objects;

drop policy if exists "bike_report_photos_insert"
on storage.objects;

drop policy if exists "bike_report_photos_update"
on storage.objects;

drop policy if exists "bike_report_photos_delete"
on storage.objects;


-- ============================================================================
-- SELECT
-- Rider: view photos belonging to their own reports
-- Admin: view all bike report photos
-- ============================================================================

create policy "bike_report_photos_select"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'bike-report-photos'
  and (
    private.is_admin()

    or

    (
      split_part(name, '/', 1) = auth.uid()::text

      and exists (
        select 1
        from public.bike_reports br
        where br.id::text = split_part(name, '/', 2)
          and br.reporter_id = auth.uid()
      )
    )
  )
);


-- ============================================================================
-- INSERT
-- Rider can only upload a photo to their own report.
--
-- Required path:
-- USER_UUID / REPORT_ID / report.webp
-- ============================================================================

create policy "bike_report_photos_insert"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'bike-report-photos'

  and split_part(name, '/', 1) = auth.uid()::text

  and split_part(name, '/', 3) = 'report.webp'

  and exists (
    select 1
    from public.bike_reports br
    where br.id::text = split_part(name, '/', 2)
      and br.reporter_id = auth.uid()
  )
);


-- ============================================================================
-- UPDATE
-- Needed because Flutter upload currently uses:
--
-- upsert: true
--
-- This allows the user to replace their own report photo.
-- ============================================================================

create policy "bike_report_photos_update"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'bike-report-photos'

  and split_part(name, '/', 1) = auth.uid()::text

  and exists (
    select 1
    from public.bike_reports br
    where br.id::text = split_part(name, '/', 2)
      and br.reporter_id = auth.uid()
  )
)
with check (
  bucket_id = 'bike-report-photos'

  and split_part(name, '/', 1) = auth.uid()::text

  and split_part(name, '/', 3) = 'report.webp'

  and exists (
    select 1
    from public.bike_reports br
    where br.id::text = split_part(name, '/', 2)
      and br.reporter_id = auth.uid()
  )
);


-- ============================================================================
-- DELETE
-- Not required yet, but allows us to implement "Remove photo" later.
-- ============================================================================

create policy "bike_report_photos_delete"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'bike-report-photos'

  and split_part(name, '/', 1) = auth.uid()::text

  and exists (
    select 1
    from public.bike_reports br
    where br.id::text = split_part(name, '/', 2)
      and br.reporter_id = auth.uid()
  )
);