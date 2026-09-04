import 'package:flutter/material.dart';

enum LegalCalloutType {
  info,
  warning,
  note,
}

class LegalSection {
  const LegalSection({
    required this.title,
    required this.paragraphs,
    this.bulletPoints = const [],
    this.calloutText,
    this.calloutIcon,
    this.calloutType = LegalCalloutType.info,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bulletPoints;
  final String? calloutText;
  final IconData? calloutIcon;
  final LegalCalloutType calloutType;
}

class LegalDocumentData {
  const LegalDocumentData({
    required this.title,
    required this.badgeText,
    required this.lastUpdated,
    required this.overview,
    required this.sections,
    required this.icon,
  });

  final String title;
  final String badgeText;
  final String lastUpdated;
  final String overview;
  final List<LegalSection> sections;
  final IconData icon;
}

abstract final class LegalContent {
  static const termsOfService = LegalDocumentData(
    title: 'Terms of Service',
    badgeText: 'LEGAL AGREEMENT',
    lastUpdated: 'Effective: September 2026 • Version 1.3',
    overview:
        'Please read these Terms of Service carefully before unlocking any bicycle or utilizing the BikeRent platform. By creating an account, scanning a bike QR code, or initiating a rental session, you agree to comply with and be bound by the terms, conditions, and safety rules set forth below.',
    icon: Icons.description_rounded,
    sections: [
      LegalSection(
        title: '1. Eligibility & User Accounts',
        paragraphs: [
          'To register and use BikeRent services, you must be at least 18 years of age (or the legal age of majority in your jurisdiction) and possess full legal capacity to enter into a binding contract.',
          'Your BikeRent account is strictly personal and non-transferable. You agree to maintain accurate, up-to-date account and contact information at all times. You are entirely responsible for all activity that occurs under your account.',
        ],
        bulletPoints: [
          'Only one active rental session is permitted per account at any given time.',
          'You may not permit third parties or minors to operate bicycles unlocked using your credentials.',
          'Notify BikeRent customer support immediately if you suspect unauthorized access to your account.',
        ],
        calloutText:
            'Account Responsibility: You remain financially and legally liable for any bike unlocked under your account until it is officially docked and the session is ended.',
        calloutIcon: Icons.verified_user_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '2. Bicycle Inspection & Pre-Ride Check',
        paragraphs: [
          'Before departing from a docking station, you are required to perform a comprehensive physical and mechanical safety check on the unlocked bicycle.',
        ],
        bulletPoints: [
          'Inspect the condition of the tires (adequate inflation and tread).',
          'Test both front and rear brakes for immediate stopping power.',
          'Ensure the handlebars, bell, seat post, and pedals are firmly secured.',
          'Verify that front and rear safety lights activate properly.',
        ],
        calloutText:
            'Reporting Faults: If you detect any defect or safety hazard prior to riding, cancel the session immediately in the app and submit a Bike Damage Report so our maintenance team can service the unit.',
        calloutIcon: Icons.build_circle_rounded,
        calloutType: LegalCalloutType.warning,
      ),
      LegalSection(
        title: '3. Pricing, Security Deposit & Payments',
        paragraphs: [
          'Rental rates are displayed transparently in the app prior to initiating a rental session. Rates comprise a base unlock fee plus per-minute or hourly usage charges.',
          'Prior to unlocking a bicycle, BikeRent places a pre-authorization hold (security deposit) on your selected payment method (e.g., PayPal). This deposit protects against damage, unreturned equipment, and extended usage.',
        ],
        bulletPoints: [
          'Upon successful docking at an authorized station, the actual rental fee is deducted from the pre-authorization deposit.',
          'The remaining excess balance is released immediately and refunded to the original payment source.',
          'Exceeding the maximum consecutive rental duration (12 hours) incurs overdue fees and may be classified as equipment theft.',
        ],
        calloutText:
            'Automatic Refund: Funds released from deposit holds typically reflect within 1 to 3 business days depending on your financial institution.',
        calloutIcon: Icons.account_balance_wallet_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '4. Safe Operation & Traffic Rules',
        paragraphs: [
          'You agree to operate the bicycle with due care and in strict compliance with all national and local road traffic regulations, speed limits, and directional signage.',
        ],
        bulletPoints: [
          'Helmet usage is strongly recommended and is mandatory where required by local statute.',
          'Never operate a bicycle while under the influence of alcohol, narcotics, medication, or any substance that impairs motor skills.',
          'Do not carry passengers, children, or pets on the bicycle. The bike is engineered for single-rider use only.',
          'The front basket is rated for cargo not exceeding 10 kg (22 lbs). Do not overload.',
          'Never use mobile devices or wear dual-ear headphones while riding.',
          'Avoid riding in extreme weather conditions such as heavy downpours, flooding, or severe winds.',
        ],
        calloutText:
            'Zero Tolerance: Riding under the influence or reckless operation results in immediate permanent account termination and referral to law enforcement.',
        calloutIcon: Icons.warning_amber_rounded,
        calloutType: LegalCalloutType.warning,
      ),
      LegalSection(
        title: '5. Station Parking, Geofencing & Return Protocol',
        paragraphs: [
          'Rides must be concluded by returning the bicycle to an authorized BikeRent docking station indicated on the in-app station map.',
          'The app utilizes high-precision GPS geofencing to verify that the bicycle is physically inside the designated station radius before allowing the session to conclude.',
        ],
        bulletPoints: [
          'Align the front wheel locking pin firmly into an open dock slot until the green confirmation signal sounds.',
          'Confirm that the app reflects "Ride Completed" and displays your receipt summary before walking away.',
          'If a station is at 100% dock capacity, navigate to the nearest nearby station with available slots indicated on your map.',
          'Abandoning a bicycle outside an official station is a severe violation and incurs an abandonment penalty fee of \$50.00 plus retrieval expenses.',
        ],
        calloutText:
            'Geofence Requirement: Ensure device GPS is active so the app can validate your arrival at the docking station.',
        calloutIcon: Icons.location_on_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '6. Damage, Loss, Theft & Rider Liabilities',
        paragraphs: [
          'You are responsible for returning the bicycle in the same physical condition in which it was unlocked, normal wear and tear excepted.',
          'In the event of an accident, collision, or property damage during your rental, you must check for injuries, contact emergency services if needed, and file an accident report with BikeRent within 12 hours.',
        ],
        bulletPoints: [
          'If a bicycle is stolen during your rental session, you must contact BikeRent support and local police immediately.',
          'Willful vandalism, negligence, or failure to return a bicycle will result in liability up to the full replacement cost of \$650.00.',
          'BikeRent is not liable for personal property lost, damaged, or stolen from bike baskets.',
        ],
        calloutText:
            'Accident Assistance: For road emergencies, contact local emergency services first (e.g. 999/911), then contact BikeRent emergency support through the app.',
        calloutIcon: Icons.shield_rounded,
        calloutType: LegalCalloutType.warning,
      ),
      LegalSection(
        title: '7. Account Suspension & Service Termination',
        paragraphs: [
          'BikeRent reserves the right to suspend or permanently deactivate any account found in violation of these Terms of Service, including non-payment of fees, repeated improper returns, or safety violations.',
          'You may request account closure at any time through the app settings, provided all active rides are completed and outstanding payments are settled in full.',
        ],
      ),
      LegalSection(
        title: '8. Governing Law & Contact Details',
        paragraphs: [
          'These terms are governed by and construed in accordance with applicable local laws. Any dispute arising out of or related to these terms shall be subject to the exclusive jurisdiction of the competent courts.',
          'For questions regarding these Terms of Service or to dispute a charge, please contact our legal and support team at legal@bikerent.app.',
        ],
      ),
    ],
  );

  static const privacyPolicy = LegalDocumentData(
    title: 'Privacy Policy',
    badgeText: 'DATA PRIVACY',
    lastUpdated: 'Effective: September 2026 • Version 1.2',
    overview:
        'BikeRent is committed to safeguarding your personal data and upholding your right to privacy. This Privacy Policy details the categories of personal and location information we collect, how it is processed and secured, and how you can exercise control over your data.',
    icon: Icons.privacy_tip_rounded,
    sections: [
      LegalSection(
        title: '1. Information We Collect',
        paragraphs: [
          'We collect information necessary to provide, optimize, and protect our bicycle sharing service and ensure smooth dock management.',
        ],
        bulletPoints: [
          'Account Data: Name, email address, phone number, and encrypted credentials provided during account setup.',
          'Precise Location (GPS): Real-time coordinates collected from your mobile device while using station maps and during active rental rides.',
          'Payment & Billing Data: Payment method tokens and transaction identifiers processed securely through PayPal. We never store raw credit card numbers on our servers.',
          'Equipment & Session Diagnostics: Bike IDs scanned, unlock timestamps, docking station IDs, trip duration, and route telemetry.',
          'Device Information: Device hardware model, operating system version, app version, and crash diagnostic logs.',
        ],
        calloutText:
            'No Passive Tracking: BikeRent only collects GPS location data when the app is in the foreground or during an ongoing rental session. We never monitor your location when the app is idle or closed without an active ride.',
        calloutIcon: Icons.my_location_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '2. How We Utilize Your Information',
        paragraphs: [
          'Your data is processed strictly for legitimate operational, safety, and regulatory purposes, including:',
        ],
        bulletPoints: [
          'Validating bike unlocking and synchronizing real-time ride durations and calculated fees.',
          'Enforcing station geofencing to confirm accurate bicycle returns and process automated deposit refunds.',
          'Preventing bike theft, unauthorized abandonment, and fraudulent transactions.',
          'Dispatching digital receipts, active rental alerts, and critical service notifications.',
          'Analyzing station usage patterns to redistribute bikes efficiently across docks.',
        ],
      ),
      LegalSection(
        title: '3. Data Sharing & Third-Party Processors',
        paragraphs: [
          'We do not sell, monetize, or rent your personal information to third-party advertising networks. We only share necessary data with trusted service providers who assist our operations:',
        ],
        bulletPoints: [
          'Payment Gateways: PayPal facilitates secure payment authorization and deposit holds under stringent PCI-DSS standards.',
          'Cloud Infrastructure: Supabase provides encrypted database storage, user authentication, and secure row-level data access.',
          'Map Providers: OpenStreetMap and map tile services are used for station navigation and geographic display.',
          'Law Enforcement: We may disclose data when legally required by law, subpoena, or to protect user life and public safety in traffic accidents.',
        ],
        calloutText:
            'No Third-Party Ads: BikeRent does not share your travel itineraries or contact information with advertisers or data brokers.',
        calloutIcon: Icons.lock_outline_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '4. Data Security & Storage Standards',
        paragraphs: [
          'We employ industry-standard administrative, physical, and technical safeguards to protect your personal information against unauthorized access, loss, or alteration.',
        ],
        bulletPoints: [
          'End-to-end encryption in transit (HTTPS / TLS 1.3) for all communication between app and server.',
          'Database encryption at rest and strict Row-Level Security (RLS) policies.',
          'Tokenized authentication with automatic session expiration.',
        ],
      ),
      LegalSection(
        title: '5. Retention of Data',
        paragraphs: [
          'We retain your personal information for as long as your BikeRent account remains active and as required to fulfill our legal obligations.',
        ],
        bulletPoints: [
          'Detailed GPS route logs are retained for 90 days to handle billing queries and incident investigations, after which they are permanently anonymized.',
          'Transaction receipts are maintained in accordance with financial and tax retention regulations.',
          'Account profile data is retained until you initiate an account deletion request.',
        ],
      ),
      LegalSection(
        title: '6. Your Rights & Privacy Controls',
        paragraphs: [
          'You hold comprehensive rights over your personal data under applicable privacy laws:',
        ],
        bulletPoints: [
          'Access & Portability: You can view your rental history, transaction records, and profile details anytime in the app.',
          'Correction: You may update or correct your profile data directly in the Profile screen.',
          'Account & Data Deletion: You may submit a request to permanently delete your account and associated personal data.',
          'Permissions Control: You can modify Camera and Location permissions anytime through your device operating system settings.',
        ],
        calloutText:
            'Permission Requirements: Camera permission is used solely for QR scanning. Location permission is required during rides for geofence return validation.',
        calloutIcon: Icons.security_rounded,
        calloutType: LegalCalloutType.info,
      ),
      LegalSection(
        title: '7. Policy Updates & Privacy Inquiries',
        paragraphs: [
          'We may revise this Privacy Policy periodically to reflect technological or legal updates. Material changes will be communicated via in-app notification.',
          'For any inquiries regarding data protection or to exercise your privacy rights, contact our Data Protection Officer at privacy@bikerent.app.',
        ],
      ),
    ],
  );
}
