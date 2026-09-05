// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'BikeRent';

  @override
  String get home => '首页';

  @override
  String get stations => '站点';

  @override
  String get bikeSession => '骑行';

  @override
  String get scan => '扫描';

  @override
  String get history => '记录';

  @override
  String get profile => '我的';

  @override
  String get adminManagement => '管理员管理';

  @override
  String get bikeManagement => '车辆管理';

  @override
  String get settings => '设置';

  @override
  String get back => '返回';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get currentRide => '当前骑行';

  @override
  String get rideInProgress => '骑行进行中。';

  @override
  String get stationsDescription => '车桩容量、附近站点与归还点。';

  @override
  String get rideHistory => '骑行记录';

  @override
  String get rideHistoryDescription => '查看过往骑行、费用与归还站点。';

  @override
  String get rideDetails => '骑行详情';

  @override
  String get pastRides => '过往骑行';

  @override
  String get totalRides => '总骑行次数';

  @override
  String get totalDistance => '总距离';

  @override
  String get totalSpent => '总花费';

  @override
  String rideHistoryEntrySemantics(
    String date,
    String time,
    String fromStation,
    String toStation,
    String duration,
    String distance,
    String fare,
  ) {
    return '$date $time 的骑行，从 $fromStation 到 $toStation，时长 $duration，距离 $distance，费用 $fare。点击查看详情。';
  }

  @override
  String get rideCompleted => '骑行完成';

  @override
  String get journeyDetails => '行程详情';

  @override
  String get from => '起点';

  @override
  String get to => '终点';

  @override
  String departedAt(String time) {
    return '于 $time 出发';
  }

  @override
  String arrivedAt(String time) {
    return '于 $time 到达';
  }

  @override
  String get rideSummary => '骑行摘要';

  @override
  String get bikeId => '车辆 ID';

  @override
  String get paymentDetails => '支付详情';

  @override
  String get depositHeld => '已冻结押金';

  @override
  String get rideFareFromDeposit => '骑行费用已从押金中扣除';

  @override
  String get depositRefunded => '剩余押金已退还';

  @override
  String get totalPaid => '已付总额';

  @override
  String get depositRefund => '押金退款';

  @override
  String get paymentMethod => '付款方式';

  @override
  String get depositPaymentExplanation => '骑行费用已从押金中扣除，剩余押金将退回至原付款方式。';

  @override
  String get profileDescription => '个人资料、钱包、权限与骑行记录。';

  @override
  String get fleetDescription => '车队健康状况、电量状态与维护队列。';

  @override
  String get adminDescription => '管理站点、车辆和用户。';

  @override
  String get stationManagement => '站点管理';

  @override
  String get stationManagementDescription => '站点、车桩容量与归还点';

  @override
  String get bikeManagementDescription => '车队健康、电量状态与维护';

  @override
  String get userManagement => '用户管理';

  @override
  String get userManagementDescription => '用户资料、钱包、权限与骑行记录';

  @override
  String get appSettings => '应用设置';

  @override
  String get appSettingsDescription => '管理外观与骑行权限。';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择您偏好的应用语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get english => '英语';

  @override
  String get malay => '马来语';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get darkTheme => '深色主题';

  @override
  String get on => '开启';

  @override
  String get off => '关闭';

  @override
  String get locationAccess => '位置权限';

  @override
  String get locationAccessDescription => '骑行进行期间需要';

  @override
  String get rideNotifications => '骑行通知';

  @override
  String get rideNotificationsDescription => '归还提醒与支付更新';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get readyToRide => '准备好骑行了吗？';

  @override
  String bikeAvailability(int bikeCount, int stationCount) {
    return '$bikeCount 辆自行车分布于 $stationCount 个站点。';
  }

  @override
  String unlockRate(String unlockFee, String minuteRate) {
    return '$unlockFee 解锁费 + 每计费分钟 $minuteRate';
  }

  @override
  String get scanBike => '扫描车辆';

  @override
  String get findStation => '查找站点';

  @override
  String get returnStationUnavailable => '当前没有可用的还车站点。';

  @override
  String get liveNetwork => '实时网络';

  @override
  String get bikes => '车辆';

  @override
  String get openDocks => '空闲车桩';

  @override
  String get nearYou => '附近';

  @override
  String get viewAll => '查看全部';

  @override
  String stationDistance(int distance) {
    return '距离 $distance 米';
  }

  @override
  String bikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 辆自行车',
    );
    return '$_temp0';
  }

  @override
  String dockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个车桩',
    );
    return '$_temp0';
  }

  @override
  String docksAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个空闲车桩',
    );
    return '$_temp0';
  }

  @override
  String get full => '已满';

  @override
  String get libraryStation => '图书馆站';

  @override
  String get mainGate => '正门站';

  @override
  String get centralStation => '中央站';

  @override
  String get riversidePark => '河滨公园站';

  @override
  String get marketSquare => '市场广场站';

  @override
  String get universityGate => '大学门站';

  @override
  String get rideConditions => '骑行条件';

  @override
  String get currentWeather => '当前天气';

  @override
  String get partlyCloudy => '局部多云';

  @override
  String feelsLike(String temperature) {
    return '体感 $temperature';
  }

  @override
  String get scatteredThunderstorms => '局部雷阵雨';

  @override
  String rainChance(int chance) {
    return '降雨概率 $chance%';
  }

  @override
  String get humidity => '湿度';

  @override
  String get airQuality => '空气质量';

  @override
  String get good => '良好';

  @override
  String get wind => '风力';

  @override
  String nextHour(String condition) {
    return '未来一小时 · $condition';
  }

  @override
  String weatherValues(String temperature, String rainChance) {
    return '$temperature · $rainChance';
  }

  @override
  String weatherUpdated(String time, String date) {
    return '更新于 $time · $date';
  }

  @override
  String rideConditionsSemantics(
    String location,
    String condition,
    String temperature,
    String feelsLike,
    String nextCondition,
    String nextTemperature,
    String rainChance,
    String humidity,
    String airQualityIndex,
    String airQualityLabel,
    String wind,
  ) {
    return '骑行条件。当前位置：$location。当前天气：$condition，$temperature，体感 $feelsLike。未来一小时：$nextCondition，$nextTemperature，$rainChance。湿度 $humidity。空气质量指数 $airQualityIndex，$airQualityLabel。风力 $wind。';
  }

  @override
  String get scanStep => '扫描';

  @override
  String get rideStep => '骑行';

  @override
  String get returnStep => '归还';

  @override
  String get payStep => '支付';

  @override
  String stepSemantics(String label) {
    return '$label步骤';
  }

  @override
  String get cameraPreviewSemantics => '相机预览。点击以扫描车身二维码。';

  @override
  String get cameraReady => '相机已就绪';

  @override
  String get cameraNoPermission => '无权限';

  @override
  String get cameraPermissionDescription => '需要相机权限才能扫描车身二维码。请点击下方以允许访问。';

  @override
  String get grantPermission => '授予权限';

  @override
  String get cameraPermissionSettingsPrompt => '需要相机权限。请在系统设置中开启相机。';

  @override
  String get pointCamera => '将相机对准车身上的二维码';

  @override
  String get scanInstructions => '扫描车身上的二维码即可开始骑行';

  @override
  String get bikeReady => '车辆已就绪';

  @override
  String get bikeReadyDescription => '执行测试预授权前，请先检查车辆与费用。';

  @override
  String bikeBatteryLocation(int battery, String location) {
    return '电量 $battery% · $location';
  }

  @override
  String get view => '查看';

  @override
  String get brakesSafe => '刹车和轮胎状况良好';

  @override
  String brakesIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刹车 / 轮胎：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get frameSafe => '车座和车架无明显损伤';

  @override
  String frameIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '车座 / 车架：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get lightsSafe => '前后车灯正常';

  @override
  String lightsIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '车灯 / 车铃：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get checkingBikeCondition => '正在检查车况报告…';

  @override
  String get reportBikeIssue => '报告车辆问题';

  @override
  String get change => '更换';

  @override
  String reviewHold(String amount) {
    return '确认 $amount 预授权';
  }

  @override
  String get cancelRental => '取消租车';

  @override
  String get holdExplanation => '预授权并非实际扣款，未使用的金额会在还车后释放。';

  @override
  String get authorizeCardHold => '发起测试预授权';

  @override
  String get authorizeCardHoldDescription => '在车辆解锁前模拟测试付款的授权确认。';

  @override
  String get temporaryAuthorizationHold => '临时预授权';

  @override
  String authorizeHold(String amount) {
    return '发起 $amount 预授权';
  }

  @override
  String get unlockBikeTitle => '解锁自行车';

  @override
  String unlockBikeDescription(String bikeId) {
    return '后锁开启时请留在 $bikeId 旁。';
  }

  @override
  String get contactingBikeLock => '正在连接车锁…';

  @override
  String get cardHoldAuthorized => '测试预授权已确认';

  @override
  String get unlockBike => '解锁车辆';

  @override
  String get rideActive => '骑行进行中';

  @override
  String get rideActiveDescription => 'GPS 将沿城市路线记录您的位置。';

  @override
  String get gpsActive => 'GPS 信号正常';

  @override
  String get gpsLost => 'GPS 信号丢失';

  @override
  String get restoreGps => '恢复 GPS';

  @override
  String get time => '时间';

  @override
  String get distance => '距离';

  @override
  String get estimated => '预计';

  @override
  String distanceKm(String distance) {
    return '$distance 公里';
  }

  @override
  String get returnBike => '归还自行车';

  @override
  String get nearestReturnStation => '最近的还车站点';

  @override
  String get otherNearbyStations => '其他附近站点';

  @override
  String get phoneSafety => '请先安全停车，再使用手机或选择站点。';

  @override
  String get continueRide => '继续骑行';

  @override
  String get chooseReturnStation => '选择还车站点';

  @override
  String get chooseReturnStationDescription => '完成骑行需要一个空闲车桩。';

  @override
  String get withinReturnZone => '已在还车区内';

  @override
  String get confirmArrival => '确认到达';

  @override
  String get continueToDock => '继续前往车桩';

  @override
  String get scanStationQr => '扫描站点二维码';

  @override
  String get scanStationQrDescription => '扫描站点处的二维码海报，或输入站点代码，以验证归还。';

  @override
  String get cameraUnavailable => '相机不可用。请改为在下方输入站点代码。';

  @override
  String get stationCodeLabel => '站点代码';

  @override
  String get stationCodeHint => '例如 CENTRAL';

  @override
  String get confirm => '确认';

  @override
  String rideDeadlineCountdown(int minutes) {
    return '还需在 $minutes 分钟内归还自行车';
  }

  @override
  String get rideOverdueTitle => '骑行超时';

  @override
  String get rideOverdueBody =>
      '您已超过最长骑行时间。请立即归还自行车——若未及时归还，本次租车将以丢失结案并停用您的账号。';

  @override
  String extendRide(int count) {
    return '延长 60 分钟（剩余 $count 次）';
  }

  @override
  String get noExtensionsLeft => '已无可用的延长次数';

  @override
  String get secureBike => '停好自行车';

  @override
  String get secureBikeDescription => '将前轮推入空闲车桩，直到锁止。';

  @override
  String get confirmBikeDocked => '确认车辆已停入车桩';

  @override
  String get rideComplete => '骑行完成';

  @override
  String get rideCompleteDescription => '车辆已固定。请查看最终费用。';

  @override
  String get unlockFee => '解锁费';

  @override
  String startedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '计费 $count 分钟',
    );
    return '$_temp0';
  }

  @override
  String get rideDuration => '骑行时长';

  @override
  String get timeFare => '计时费';

  @override
  String hourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时',
    );
    return '$_temp0';
  }

  @override
  String minuteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟',
    );
    return '$_temp0';
  }

  @override
  String get finalFare => '最终费用';

  @override
  String get holdReleased => '预授权已释放';

  @override
  String chargeAmount(String amount) {
    return '扣款 $amount';
  }

  @override
  String get ridePaid => '骑行费用已支付';

  @override
  String get paymentPending => '骑行已结束 · 待支付';

  @override
  String get holdReleasedDescription => '剩余测试预授权已释放。';

  @override
  String get paymentPendingDescription => '自行车已安全归还。请点击下方重试模拟扣款。';

  @override
  String get rideId => '骑行 ID';

  @override
  String get duration => '时长';

  @override
  String get returnedAt => '归还时间';

  @override
  String get retryPayment => '重试支付';

  @override
  String get retry => '重试';

  @override
  String get rentAnotherBike => '再租一辆';

  @override
  String get pleaseWait => '请稍候…';

  @override
  String get timeBasedPricing => '计时计费';

  @override
  String pricingFormula(String unlockFee, String minuteRate) {
    return '$unlockFee +（计费分钟数 × $minuteRate）';
  }

  @override
  String pricingExample(int minutes) {
    return '$minutes 分钟示例';
  }

  @override
  String get pricingTimerDescription => '计时器在车辆解锁后启动，车桩确认归还后停止。';

  @override
  String get choosePaymentMethod => '选择付款方式';

  @override
  String get personalCard => '个人银行卡';

  @override
  String get travelCard => '交通卡';

  @override
  String get addCardFuture => '添加新卡片的功能将在未来的用户模块中提供。';

  @override
  String get paypalSandbox => '测试支付';

  @override
  String get paypalSandboxDescription => '本地模拟 · 不涉及真实资金';

  @override
  String get paypalAccountSubtitle => 'PayPal 沙盒账户';

  @override
  String get paypalCheckoutTitle => 'PayPal 付款';

  @override
  String get paypalCheckoutSemantics => '安全的 PayPal 付款确认页';

  @override
  String get selected => '已选择';

  @override
  String get selectable => '可选择';

  @override
  String get cityMapSemantics => '城市地图，显示当前车辆位置与还车站点';

  @override
  String get errorInvalidQr => '这个二维码不是 BikeRent 车辆。请扫描车身上的二维码。';

  @override
  String errorBikeReserved(String bikeId) {
    return '自行车 $bikeId 已被预约。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeMaintenance(String bikeId) {
    return '自行车 $bikeId 正在维护中，无法租用。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeUnavailable(String bikeId) {
    return '自行车 $bikeId 目前不可用，无法租用。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeLowBattery(String bikeId, int percent) {
    return '自行车 $bikeId 电量过低（$percent%），无法租用。最低要求为 10%。请选择其他车辆并重新扫描。';
  }

  @override
  String get lowBatteryWarningTitle => '电量不足警告';

  @override
  String lowBatteryWarningMessage(String bikeId, int percent) {
    return '自行车 $bikeId 电量仅剩 $percent%。骑行距离和电机助力可能受限。要继续吗？';
  }

  @override
  String get continueButton => '继续';

  @override
  String get bikeCannotBeRentedTitle => '无法租用此自行车';

  @override
  String errorHoldDeclined(String amount) {
    return '$amount 测试预授权被拒绝。准备好后可重试。';
  }

  @override
  String get errorPaymentConfiguration => '本地测试付款模拟器不可用。';

  @override
  String get errorPaymentNetwork => '本地测试付款失败。准备好后可重试。';

  @override
  String get errorPaymentCancelled => '测试付款确认已被取消。准备好后可重试。';

  @override
  String get errorPaymentAuthorizationFailed => '测试付款无法完成预授权。准备好后可重试。';

  @override
  String get errorPaymentCaptureFailed => '测试付款无法扣取骑行费用。付款仍处于待处理状态，请在下方重试。';

  @override
  String get errorLockFailed => '车锁没有响应。请靠近车辆后重试。';

  @override
  String get errorGpsLost => 'GPS 信号丢失。请移至开阔区域并检查位置权限。';

  @override
  String errorStationFull(String station) {
    return '$station 没有空闲车桩。请选择其他站点。';
  }

  @override
  String get errorChooseStation => '请先选择还车站点。';

  @override
  String get errorOutsideReturnZone => '归还前请移动到所选站点 250 米范围内。';

  @override
  String get errorStationQrMismatch => '该二维码与所选站点不符。请扫描站点处的二维码海报或输入站点代码。';

  @override
  String get errorMaxExtensionsReached => '延长次数已用完。请归还自行车以结束本次租车。';

  @override
  String get errorLocationPermissionDenied => '需要位置权限才能验证归还。请开启后重试。';

  @override
  String get errorAccountSuspended => '账号已停用：您有一辆自行车未归还。请联系客服以恢复。';

  @override
  String get errorDockNotDetected => '未检测到车桩。请将自行车用力推入车桩后重试。';

  @override
  String get errorAuthenticationFailed => '演示骑手登录失败。请检查 Supabase 后重试。';

  @override
  String get errorBackendConnection => '租车服务不可用。请检查网络连接后重试。';

  @override
  String get errorActiveRentalExists => '该骑手还有未完成的租车。请先继续或完成。';

  @override
  String errorStationMaintenance(String station) {
    return '站点 $station 正在维护中，无法在此租车或还车。';
  }

  @override
  String errorStationTerminated(String station) {
    return '站点 $station 已终止，无法在此租车或还车。';
  }

  @override
  String get errorStationMaintenanceGeneral => '该站点正在维护中，无法在此租车或还车。';

  @override
  String get errorStationTerminatedGeneral => '该站点已终止，无法在此租车或还车。';

  @override
  String get stationUnderMaintenance => '维护中';

  @override
  String get stationCannotReturnMaintenance => '该站点正在维护中，无法在此归还自行车。';

  @override
  String get errorInvalidRentalTransition => '服务器上的租车状态已变更。请重试以恢复。';

  @override
  String get rideWarningDepositExceededTitle => '超出押金时限';

  @override
  String get rideWarningDepositExceededBody => '您借用自行车的时间已超过押金时限，将产生额外租车费用。';

  @override
  String get rideWarningLegalActionTitle => '法律行动警告';

  @override
  String get rideWarningLegalActionBody =>
      '租赁时长已超过押金时限的 2 倍。若不及时归还自行车，将立即采取法律行动。';

  @override
  String get rideWarningSuspiciousActivityTitle => '检测到可疑活动';

  @override
  String get rideWarningSuspiciousActivityBody => '检测到可疑活动：您距离取车站点异常遥远。';

  @override
  String get rideWarningSuspiciousLegalTitle => '可疑活动与法律行动';

  @override
  String get rideWarningSuspiciousLegalBody =>
      '检测到远离站点的可疑活动，且已超出押金时限。若未归还自行车，将立即采取法律行动。';

  @override
  String get addBike => '添加车辆';

  @override
  String get editBike => '编辑车辆';

  @override
  String get bikeDetail => '车辆详情';

  @override
  String get bikeReport => '车辆报告';

  @override
  String get transferBike => '转移车辆';

  @override
  String get serviceBike => '检修车辆';

  @override
  String get reportDetail => '报告详情';

  @override
  String get pendingReports => '待处理报告';

  @override
  String get newReport => '新报告';

  @override
  String get pendingReportDetails => '待处理报告详情';

  @override
  String get paymentMethods => '付款方式';

  @override
  String get conditionReports => '车况报告';

  @override
  String get reviewAndResolveBikeIssues => '审核并处理车辆问题。';

  @override
  String get trackSubmittedBikeReports => '追踪您提交的车辆报告。';

  @override
  String get searchReportOrBikeId => '搜索报告或车辆 ID';

  @override
  String get pending => '待处理';

  @override
  String get approved => '已通过';

  @override
  String get rejected => '已拒绝';

  @override
  String get cancelled => '已取消';

  @override
  String get reports => '报告';

  @override
  String get newestFirst => '最新优先';

  @override
  String get cancelReport => '取消报告';

  @override
  String get cancelReportQuestion => '取消报告？';

  @override
  String get keepReport => '保留报告';

  @override
  String cancelReportConfirmation(String reportId) {
    return '取消 $reportId？该报告将不再由管理员审核。';
  }

  @override
  String reportCancelled(String reportId) {
    return '已取消 $reportId。';
  }

  @override
  String failedToCancelReport(String error) {
    return '取消报告失败：$error';
  }

  @override
  String get onlyPendingReportsCanBeCancelled => '只有待处理的报告可以取消。';

  @override
  String allReports(int count) {
    return '全部 $count';
  }

  @override
  String pendingReportsCount(int count) {
    return '待处理 $count';
  }

  @override
  String approvedReportsCount(int count) {
    return '已通过 $count';
  }

  @override
  String rejectedReportsCount(int count) {
    return '已拒绝 $count';
  }

  @override
  String cancelledReportsCount(int count) {
    return '已取消 $count';
  }

  @override
  String get noMatchingReports => '没有匹配的报告';

  @override
  String get noReportsYet => '暂无报告';

  @override
  String get tryDifferentSearchTerm => '请尝试其他搜索关键词。';

  @override
  String get bikeConditionReportsAppearHere => '车况报告将显示在这里。';

  @override
  String get reported => '已报告';

  @override
  String get unableToLoadReports => '无法加载报告';

  @override
  String get brakeSystem => '刹车系统';

  @override
  String get tyres => '轮胎';

  @override
  String get chainAndGears => '链条与变速';

  @override
  String get seatAndFrame => '车座与车架';

  @override
  String get bellAndLights => '车铃与车灯';

  @override
  String get qrLock => '二维码 / 车锁';

  @override
  String get other => '其他';

  @override
  String get unableToLoadReport => '无法加载报告';

  @override
  String get reportNotFound => '未找到报告';

  @override
  String get reportDetails => '报告详情';

  @override
  String get noStationAssigned => '未分配站点';

  @override
  String get reportInformation => '报告信息';

  @override
  String get problem => '问题';

  @override
  String get reportIdLabel => '报告 ID';

  @override
  String get photo => '照片';

  @override
  String get photoUnavailable => '照片不可用';

  @override
  String get photoCouldNotBeLoaded => '报告照片无法加载。';

  @override
  String get unableToDisplayPhoto => '无法显示照片';

  @override
  String get attachedPhotoCouldNotBeDisplayed => '附加照片无法显示。';

  @override
  String get noPhotoAttached => '未附照片';

  @override
  String get reportWithoutPhoto => '此报告提交时未附照片。';

  @override
  String get issueDescription => '问题描述';

  @override
  String get pendingReview => '待审核';

  @override
  String get pendingReviewDescription => '此报告尚未审核。';

  @override
  String get reportApproved => '报告已通过';

  @override
  String get reportRejected => '报告已拒绝';

  @override
  String get reviewed => '已审核';

  @override
  String get reviewNote => '审核备注';

  @override
  String get noReviewNoteProvided => '未提供审核备注。';

  @override
  String get reportCancelledStatus => '报告已取消';

  @override
  String get reportCancelledDescription => '您在审核前取消了此报告。';

  @override
  String get addNewBike => '添加新车辆';

  @override
  String get step1BasicInformation => '第 1 步（共 3 步）• 基本信息';

  @override
  String get step2QrCode => '第 2 步（共 3 步）• 二维码';

  @override
  String get step3ReviewInformation => '第 3 步（共 3 步）• 核对信息';

  @override
  String get bikeCode => '车辆代码';

  @override
  String get enterBikeCode => '输入车辆代码';

  @override
  String get bikeCodeTooShort => '车辆代码过短';

  @override
  String get initialStation => '初始站点';

  @override
  String get pleaseSelectStation => '请选择站点';

  @override
  String get selectStation => '选择站点';

  @override
  String get unableToLoadStations => '无法加载站点';

  @override
  String get noStationsAvailable => '暂无可用站点。';

  @override
  String get noStationSelected => '未选择站点';

  @override
  String get batteryPercentage => '电量百分比';

  @override
  String get enterBatteryPercentage => '输入电量百分比';

  @override
  String get invalidBatteryPercentage => '电量百分比无效';

  @override
  String get enterValidNumber => '请输入有效数字';

  @override
  String get batteryRangeError => '电量必须在 0 到 100 之间';

  @override
  String get battery => '电量';

  @override
  String get initialStatus => '初始状态';

  @override
  String get status => '状态';

  @override
  String get available => '可用';

  @override
  String get maintenance => '维护中';

  @override
  String get retired => '已退役';

  @override
  String get qrGeneratedAutomatically => '系统将自动生成唯一的二维码令牌。';

  @override
  String get qrScanningDescription => '二维码之后可包含此令牌，供扫描车辆时使用。';

  @override
  String get bikeQrCode => '车辆二维码';

  @override
  String get qrTokenIdentifiesBike => '扫描时将使用以下令牌识别此车辆。';

  @override
  String get qrToken => 'QR 令牌';

  @override
  String get qrTokenNotGenerated => '二维码令牌尚未生成';

  @override
  String get notGenerated => '未生成';

  @override
  String get qrPlaceholderDescription => '当前的二维码图片仅为占位图。之后我们可以根据该令牌生成实际的二维码。';

  @override
  String get generatedQrCode => '已生成的二维码';

  @override
  String get next => '下一步';

  @override
  String get bikeInformation => '车辆信息';

  @override
  String get notSelected => '未选择';

  @override
  String get bikeAddedSuccessfully => '车辆添加成功';

  @override
  String failedToAddBike(String error) {
    return '添加车辆失败：$error';
  }

  @override
  String get managePaymentMethodsSubtitle => '管理银行卡与 PayPal';

  @override
  String get termsOfService => '服务条款';

  @override
  String get termsOfServiceSubtitle => '租赁规则、安全政策与责任条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicySubtitle => '数据保护、GPS 定位与隐私权利';

  @override
  String get logOut => '退出登录';

  @override
  String get onlineCheckout => '在线结账';

  @override
  String get savedCards => '已保存的卡片';

  @override
  String savedCardsCount(int count) {
    return '已保存 $count 张';
  }

  @override
  String get noCardsSaved => '还没有保存的卡片';

  @override
  String get noCardsSavedDescription => '添加 Visa 或 Mastercard，即可快速便捷地一键租车。';

  @override
  String get addCard => '添加卡片';

  @override
  String get removeCard => '移除卡片';

  @override
  String removeCardConfirmation(String brand, String lastFour) {
    return '确定要移除尾号为 $lastFour 的 $brand 卡片吗？';
  }

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get cardRemovedSuccess => '卡片移除成功';

  @override
  String get failedToRemoveCard => '卡片移除失败';

  @override
  String cardSetAsDefault(String brand) {
    return '$brand 已设为默认付款方式';
  }

  @override
  String get failedToUpdateDefaultCard => '更新默认卡片失败';

  @override
  String get editCard => '编辑卡片';

  @override
  String get cardUpdatedSuccess => '卡片更新成功';

  @override
  String get failedToUpdateCard => '卡片更新失败';

  @override
  String get cardAddedSuccess => '卡片添加成功';

  @override
  String get failedToAddCard => '卡片添加失败';

  @override
  String get cardNumber => '卡号';

  @override
  String get cardNumberHint => '4xxx xxxx xxxx xxxx';

  @override
  String get cardholderName => '持卡人姓名';

  @override
  String get cardholderNameHint => '例如：张三';

  @override
  String get expiryDate => '有效期';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get cvvCvc => 'CVV / CVC';

  @override
  String get cvvHint => '•••';

  @override
  String get setAsDefaultPaymentMethod => '设为默认付款方式';

  @override
  String get automaticallyUseCard => '租车时自动使用此卡';

  @override
  String get updateCard => '更新卡片';

  @override
  String cardExpiry(String month, String year) {
    return '$month/$year 到期';
  }

  @override
  String get activeCard => '启用中的卡片';

  @override
  String get defaultBadge => '默认';

  @override
  String get cardOptions => '卡片选项';

  @override
  String get setAsDefault => '设为默认';

  @override
  String get editCardMenu => '编辑卡片';

  @override
  String get removeCardMenu => '移除卡片';

  @override
  String get payPal => 'PayPal';

  @override
  String get payPalBuiltIn => '内置';

  @override
  String get payPalSubtitle => 'WebView 结账 · 始终可用';

  @override
  String get payPalInformation => 'PayPal 信息';

  @override
  String get payPalIntegration => 'PayPal 集成';

  @override
  String get payPalAlwaysAvailable => '始终可用的付款方式';

  @override
  String get payPalDescription =>
      'PayPal 结账通过应用内安全的 WebView 在租车授权时按需处理。它无需保存信用卡或借记卡信息，因此无法编辑或移除。';

  @override
  String get gotIt => '知道了';

  @override
  String get cardholderPreview => '持卡人';

  @override
  String get cardholderNamePreview => '持卡人姓名';

  @override
  String get expiresPreview => '有效期至';

  @override
  String get agree => '同意';

  @override
  String get agreementConfirmation => '协议确认';

  @override
  String agreementNotice(String buttonText, String title) {
    return '点击上方或下方的“$buttonText”，即表示您已阅读并接受这些$title。';
  }

  @override
  String agreeAndContinue(String buttonText) {
    return '$buttonText并继续';
  }

  @override
  String get contactSupport => '有疑问？请联系 support@bikerent.app';

  @override
  String errorLoadingStations(String error) {
    return '加载站点失败：$error';
  }

  @override
  String get stationA => '站点 A';

  @override
  String get stationB => '站点 B';

  @override
  String get selectOriginStation => '选择起点站点';

  @override
  String get selectDestinationStation => '选择终点站点';

  @override
  String get underMaintenance => '维护中';

  @override
  String get selectedStationTooFar => '所选站点距离过远';

  @override
  String get etaLabel => '预计到达：';

  @override
  String get estimatedArrivalTime => '预计到达时间（ETA）';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String totalDistanceKm(String distance) {
    return '总距离：$distance 公里';
  }

  @override
  String get selectStationsToCalculateRoutePrompt => '请选择站点 A 和站点 B 以计算路线。';

  @override
  String failedToLoadBikes(String error) {
    return '加载车辆失败：$error';
  }

  @override
  String get invalidBikeIdError => '无法打开：车辆 ID 无效';

  @override
  String get stationBikes => '站点车辆';

  @override
  String get locationCoordinatesNotProvided => '未提供位置坐标';

  @override
  String get searchBikesCodeOrId => '按代码或 ID 搜索车辆';

  @override
  String get noBikesInStationYet => '该站点还没有自行车';

  @override
  String get noBikesMatchSearch => '没有符合搜索条件的车辆。';

  @override
  String get unknownStatus => '未知';

  @override
  String bikeStatus(String status) {
    return '状态：$status';
  }

  @override
  String failedToLoadStations(String error) {
    return '加载站点失败：$error';
  }

  @override
  String get searchStationHint => '搜索站点代码、名称或地址…';

  @override
  String get longPressMapToAddStation => '长按地图添加新站点';

  @override
  String get noMatchingStationsFound => '未找到匹配的站点。';

  @override
  String get unnamedStation => '未命名站点';

  @override
  String get noAddress => '无地址';

  @override
  String get stationNameEmptyError => '站点名称不能为空。';

  @override
  String get stationAddressEmptyError => '站点地址不能为空。';

  @override
  String get validCapacityError => '请输入有效的最大容量数字。';

  @override
  String maxCapacityExceededError(int capacity, int bikes) {
    return '最大容量（$capacity）不能少于当前停放的车辆数（$bikes）。';
  }

  @override
  String get stationUpdatedSuccess => '站点更新成功！';

  @override
  String get stationAddedSuccess => '站点添加成功！';

  @override
  String failedToSaveStation(String error) {
    return '保存站点失败：$error';
  }

  @override
  String get removeStation => '移除站点';

  @override
  String get confirmRemoveStationBody => '确定要移除此站点吗？';

  @override
  String get stationRemovedSuccess => '站点移除成功！';

  @override
  String failedToRemoveStation(String error) {
    return '移除站点失败：$error';
  }

  @override
  String get changePhoto => '更换照片';

  @override
  String get stationName => '站点名称';

  @override
  String get enterStationNameHint => '输入站点名称…';

  @override
  String get stationCode => '站点代码';

  @override
  String get readOnly => '只读';

  @override
  String get address => '地址';

  @override
  String get enterStationAddressHint => '输入站点地址…';

  @override
  String get operatingStatus => '运营状态';

  @override
  String get currentDockedBikes => '当前停放车辆数';

  @override
  String get maxBikesPerStation => '每站最大车辆数';

  @override
  String get addStation => '添加站点';

  @override
  String get updateStation => '更新站点';

  @override
  String get viewBikesAtStation => '查看站点车辆';

  @override
  String get noAddressSet => '未设置地址';

  @override
  String get noBikesAtStation => '此站点暂无车辆。';

  @override
  String stationDeactivatedSuccess(String stationName) {
    return '$stationName 已成功停用';
  }

  @override
  String get searchStationToRemove => '搜索要移除的站点…';

  @override
  String get searchStationNameOrAddress => '搜索站点名称或地址…';

  @override
  String get noStationsFound => '未找到站点。';

  @override
  String bikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 辆自行车',
    );
    return '$_temp0';
  }

  @override
  String get currentlySelected => '当前已选择';

  @override
  String get targetStationToRemove => '要移除的目标站点';

  @override
  String get closestToYou => '离您最近';

  @override
  String get reset => '重置';

  @override
  String get allActiveStations => '所有运营中的站点';

  @override
  String get nearbyStations => '附近站点';

  @override
  String stationSummarySubtitle(String address, int count, String distance) {
    return '$address • $count 辆自行车$distance';
  }

  @override
  String confirmRemoveStationTitle(String stationName) {
    return '确定要移除\n$stationName 吗？';
  }

  @override
  String get actionIrreversibleWarning => '此操作不可撤销，确定要继续吗？';

  @override
  String get removeLocation => '移除位置';

  @override
  String get okButton => '确定';

  @override
  String get scanningLabel => '正在扫描…';

  @override
  String get flashlightTooltip => '手电筒';

  @override
  String get invalidQrTitle => '无效的二维码';

  @override
  String reservationExpiresIn(String time) {
    return '预约将在 $time 后过期';
  }

  @override
  String get rentalTimedOutTitle => '租车超时';

  @override
  String rentalTimedOutBody(int minutes) {
    return '您的自行车预约已超过 $minutes 分钟时限，车辆已被释放。';
  }

  @override
  String get forceEndedTitle => '管理员已结束本次租车';

  @override
  String get rentalEndedTitle => '租车已结束';

  @override
  String get rentalEndedBody => '您的租车已结束。随时可以开始新的骑行。';

  @override
  String returnAtStation(String station) {
    return '在 $station 归还';
  }

  @override
  String get originStation => '起点站点';

  @override
  String get tripStartedHere => '行程由此开始';

  @override
  String get currentLocation => '当前位置';

  @override
  String get yourGpsPosition => '您的 GPS 位置';

  @override
  String get stationDetailsTooltip => '站点详情';

  @override
  String get addPaymentMethod => '添加付款方式';

  @override
  String get lowBatteryFallbackBike => '这辆自行车';

  @override
  String get errorStationFullGeneral => '附近站点目前没有空闲车桩，请稍后再试。';

  @override
  String get termsNoticePrefix => '继续进行租车流程，即视为您已阅读并接受本应用的';

  @override
  String get termsNoticeMiddle => '和';

  @override
  String get termsNoticeSuffix => '。';

  @override
  String get rideHistoryLoadFailed => '无法加载骑行记录。';

  @override
  String get noCompletedRides => '还没有已完成的骑行。';

  @override
  String get weatherConnectionFailedTitle => '连接失败';

  @override
  String get weatherConnectionFailedBody => '无法连接天气服务。请检查网络连接后重试。';

  @override
  String get weatherTimeoutTitle => '连接超时';

  @override
  String get weatherTimeoutBody => '天气服务响应时间过长。请检查网络连接后重试。';

  @override
  String get weatherRateLimitTitle => '已达请求上限';

  @override
  String get weatherRateLimitBody => '天气服务暂时繁忙。请稍候片刻后重试。';

  @override
  String get weatherLocationTitle => '位置不可用';

  @override
  String get weatherLocationBody => '需要位置权限才能显示当前天气。请开启 GPS 并授予权限。';

  @override
  String get weatherOutsideMalaysiaTitle => '超出服务范围';

  @override
  String get weatherOutsideMalaysiaBody => '天气预报仅限马来西亚境内的位置可用。';

  @override
  String get weatherServiceTitle => '服务不可用';

  @override
  String get weatherServiceBody => '天气服务暂时不可用。请稍后重试。';

  @override
  String get weatherNotFoundTitle => '天气不可用';

  @override
  String get weatherNotFoundBody => '未找到该位置的天气预报。';

  @override
  String get weatherGenericTitle => '天气不可用';

  @override
  String get weatherGenericBody => '目前无法加载骑行条件。请重试。';

  @override
  String get aqiModerate => '中等';

  @override
  String get aqiUnhealthy => '不健康';

  @override
  String get aqiVeryUnhealthy => '非常不健康';

  @override
  String get aqiHazardous => '危险';

  @override
  String get rideConditionsRateLimitSemantics => '骑行条件。已达请求上限。';

  @override
  String rideConditionsErrorSemantics(String title, String message) {
    return '骑行条件。$title：$message。';
  }

  @override
  String get pmSessionExpired => '登录已过期，请重新登录。';

  @override
  String get pmCardInUse => '无法删除卡片：该卡片已关联进行中或待处理的租车。';

  @override
  String get pmDuplicateCard => '此卡片已添加到您的账户。';

  @override
  String pmValidationError(String detail) {
    return '验证错误：$detail';
  }

  @override
  String get pmUnknownError => '发生意外错误，请重试。';

  @override
  String get cvCardNumberRequired => '请输入卡号';

  @override
  String get cvCardDigitsOnly => '请输入有效的卡号数字';

  @override
  String get cvCardBrandUnsupported => '仅支持 Visa 和 Mastercard';

  @override
  String cvCardNumberLength(int entered) {
    return '卡号必须为 16 位（已输入 $entered/16）';
  }

  @override
  String get cvCardNumberTooLong => '卡号不能超过 16 位';

  @override
  String get cvCardChecksumFailed => '卡号无效（校验失败）';

  @override
  String get cvExpiryRequired => '请输入有效期';

  @override
  String get cvExpiryFormat => '有效期请按 MM/YY 格式输入';

  @override
  String get cvExpiryInvalidMonth => '月份无效（应为 01–12）';

  @override
  String get cvExpiryInvalidYear => '有效期年份无效';

  @override
  String get cvCardExpired => '卡片已过期';

  @override
  String get cvExpiryTooFar => '有效期年份过远';

  @override
  String get cvCvvRequired => '请输入 CVV 码';

  @override
  String get cvCvvLength => 'CVV 码必须为 3 位';

  @override
  String get cvNameRequired => '请输入持卡人姓名';

  @override
  String get cvNameTooShort => '姓名至少需要 2 个字符';

  @override
  String get cvNameTooLong => '姓名不能超过 50 个字符';

  @override
  String get cvNameInvalidChars => '仅支持字母、空格、连字符和点号';

  @override
  String get cvNameNeedsTwoParts => '请输入名字和姓氏';

  @override
  String get cvNameDuplicate => '持卡人姓名已被其他卡片使用';

  @override
  String get verificationRequiredTitle => '需要身份验证';

  @override
  String get verificationRequiredBody => '租借车辆前，请先添加身份证号并完成人脸识别验证。';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class AppLocalizationsZhCn extends AppLocalizationsZh {
  AppLocalizationsZhCn() : super('zh_CN');

  @override
  String get appName => 'BikeRent';

  @override
  String get home => '首页';

  @override
  String get stations => '站点';

  @override
  String get bikeSession => '骑行';

  @override
  String get scan => '扫描';

  @override
  String get history => '记录';

  @override
  String get profile => '我的';

  @override
  String get adminManagement => '管理员管理';

  @override
  String get bikeManagement => '车辆管理';

  @override
  String get settings => '设置';

  @override
  String get back => '返回';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get currentRide => '当前骑行';

  @override
  String get rideInProgress => '骑行进行中。';

  @override
  String get stationsDescription => '车桩容量、附近站点与归还点。';

  @override
  String get rideHistory => '骑行记录';

  @override
  String get rideHistoryDescription => '查看过往骑行、费用与归还站点。';

  @override
  String get rideDetails => '骑行详情';

  @override
  String get pastRides => '过往骑行';

  @override
  String get totalRides => '总骑行次数';

  @override
  String get totalDistance => '总距离';

  @override
  String get totalSpent => '总花费';

  @override
  String rideHistoryEntrySemantics(
    String date,
    String time,
    String fromStation,
    String toStation,
    String duration,
    String distance,
    String fare,
  ) {
    return '$date $time 的骑行，从 $fromStation 到 $toStation，时长 $duration，距离 $distance，费用 $fare。点击查看详情。';
  }

  @override
  String get rideCompleted => '骑行完成';

  @override
  String get journeyDetails => '行程详情';

  @override
  String get from => '起点';

  @override
  String get to => '终点';

  @override
  String departedAt(String time) {
    return '于 $time 出发';
  }

  @override
  String arrivedAt(String time) {
    return '于 $time 到达';
  }

  @override
  String get rideSummary => '骑行摘要';

  @override
  String get bikeId => '车辆 ID';

  @override
  String get paymentDetails => '支付详情';

  @override
  String get depositHeld => '已冻结押金';

  @override
  String get rideFareFromDeposit => '骑行费用已从押金中扣除';

  @override
  String get depositRefunded => '剩余押金已退还';

  @override
  String get totalPaid => '已付总额';

  @override
  String get depositRefund => '押金退款';

  @override
  String get paymentMethod => '付款方式';

  @override
  String get depositPaymentExplanation => '骑行费用已从押金中扣除，剩余押金将退回至原付款方式。';

  @override
  String get profileDescription => '个人资料、钱包、权限与骑行记录。';

  @override
  String get fleetDescription => '车队健康状况、电量状态与维护队列。';

  @override
  String get adminDescription => '管理站点、车辆和用户。';

  @override
  String get stationManagement => '站点管理';

  @override
  String get stationManagementDescription => '站点、车桩容量与归还点';

  @override
  String get bikeManagementDescription => '车队健康、电量状态与维护';

  @override
  String get userManagement => '用户管理';

  @override
  String get userManagementDescription => '用户资料、钱包、权限与骑行记录';

  @override
  String get appSettings => '应用设置';

  @override
  String get appSettingsDescription => '管理外观与骑行权限。';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择您偏好的应用语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get english => '英语';

  @override
  String get malay => '马来语';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get darkTheme => '深色主题';

  @override
  String get on => '开启';

  @override
  String get off => '关闭';

  @override
  String get locationAccess => '位置权限';

  @override
  String get locationAccessDescription => '骑行进行期间需要';

  @override
  String get rideNotifications => '骑行通知';

  @override
  String get rideNotificationsDescription => '归还提醒与支付更新';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get readyToRide => '准备好骑行了吗？';

  @override
  String bikeAvailability(int bikeCount, int stationCount) {
    return '$bikeCount 辆自行车分布于 $stationCount 个站点。';
  }

  @override
  String unlockRate(String unlockFee, String minuteRate) {
    return '$unlockFee 解锁费 + 每计费分钟 $minuteRate';
  }

  @override
  String get scanBike => '扫描车辆';

  @override
  String get findStation => '查找站点';

  @override
  String get returnStationUnavailable => '当前没有可用的还车站点。';

  @override
  String get liveNetwork => '实时网络';

  @override
  String get bikes => '车辆';

  @override
  String get openDocks => '空闲车桩';

  @override
  String get nearYou => '附近';

  @override
  String get viewAll => '查看全部';

  @override
  String stationDistance(int distance) {
    return '距离 $distance 米';
  }

  @override
  String bikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 辆自行车',
    );
    return '$_temp0';
  }

  @override
  String dockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个车桩',
    );
    return '$_temp0';
  }

  @override
  String docksAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个空闲车桩',
    );
    return '$_temp0';
  }

  @override
  String get full => '已满';

  @override
  String get libraryStation => '图书馆站';

  @override
  String get mainGate => '正门站';

  @override
  String get centralStation => '中央站';

  @override
  String get riversidePark => '河滨公园站';

  @override
  String get marketSquare => '市场广场站';

  @override
  String get universityGate => '大学门站';

  @override
  String get rideConditions => '骑行条件';

  @override
  String get currentWeather => '当前天气';

  @override
  String get partlyCloudy => '局部多云';

  @override
  String feelsLike(String temperature) {
    return '体感 $temperature';
  }

  @override
  String get scatteredThunderstorms => '局部雷阵雨';

  @override
  String rainChance(int chance) {
    return '降雨概率 $chance%';
  }

  @override
  String get humidity => '湿度';

  @override
  String get airQuality => '空气质量';

  @override
  String get good => '良好';

  @override
  String get wind => '风力';

  @override
  String nextHour(String condition) {
    return '未来一小时 · $condition';
  }

  @override
  String weatherValues(String temperature, String rainChance) {
    return '$temperature · $rainChance';
  }

  @override
  String weatherUpdated(String time, String date) {
    return '更新于 $time · $date';
  }

  @override
  String rideConditionsSemantics(
    String location,
    String condition,
    String temperature,
    String feelsLike,
    String nextCondition,
    String nextTemperature,
    String rainChance,
    String humidity,
    String airQualityIndex,
    String airQualityLabel,
    String wind,
  ) {
    return '骑行条件。当前位置：$location。当前天气：$condition，$temperature，体感 $feelsLike。未来一小时：$nextCondition，$nextTemperature，$rainChance。湿度 $humidity。空气质量指数 $airQualityIndex，$airQualityLabel。风力 $wind。';
  }

  @override
  String get scanStep => '扫描';

  @override
  String get rideStep => '骑行';

  @override
  String get returnStep => '归还';

  @override
  String get payStep => '支付';

  @override
  String stepSemantics(String label) {
    return '$label步骤';
  }

  @override
  String get cameraPreviewSemantics => '相机预览。点击以扫描车身二维码。';

  @override
  String get cameraReady => '相机已就绪';

  @override
  String get cameraNoPermission => '无权限';

  @override
  String get cameraPermissionDescription => '需要相机权限才能扫描车身二维码。请点击下方以允许访问。';

  @override
  String get grantPermission => '授予权限';

  @override
  String get cameraPermissionSettingsPrompt => '需要相机权限。请在系统设置中开启相机。';

  @override
  String get pointCamera => '将相机对准车身上的二维码';

  @override
  String get scanInstructions => '扫描车身上的二维码即可开始骑行';

  @override
  String get bikeReady => '车辆已就绪';

  @override
  String get bikeReadyDescription => '执行测试预授权前，请先检查车辆与费用。';

  @override
  String bikeBatteryLocation(int battery, String location) {
    return '电量 $battery% · $location';
  }

  @override
  String get view => '查看';

  @override
  String get brakesSafe => '刹车和轮胎状况良好';

  @override
  String brakesIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '刹车 / 轮胎：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get frameSafe => '车座和车架无明显损伤';

  @override
  String frameIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '车座 / 车架：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get lightsSafe => '前后车灯正常';

  @override
  String lightsIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '车灯 / 车铃：已报告 $count 个问题',
    );
    return '$_temp0';
  }

  @override
  String get checkingBikeCondition => '正在检查车况报告…';

  @override
  String get reportBikeIssue => '报告车辆问题';

  @override
  String get change => '更换';

  @override
  String reviewHold(String amount) {
    return '确认 $amount 预授权';
  }

  @override
  String get cancelRental => '取消租车';

  @override
  String get holdExplanation => '预授权并非实际扣款，未使用的金额会在还车后释放。';

  @override
  String get authorizeCardHold => '发起测试预授权';

  @override
  String get authorizeCardHoldDescription => '在车辆解锁前模拟测试付款的授权确认。';

  @override
  String get temporaryAuthorizationHold => '临时预授权';

  @override
  String authorizeHold(String amount) {
    return '发起 $amount 预授权';
  }

  @override
  String get unlockBikeTitle => '解锁自行车';

  @override
  String unlockBikeDescription(String bikeId) {
    return '后锁开启时请留在 $bikeId 旁。';
  }

  @override
  String get contactingBikeLock => '正在连接车锁…';

  @override
  String get cardHoldAuthorized => '测试预授权已确认';

  @override
  String get unlockBike => '解锁车辆';

  @override
  String get rideActive => '骑行进行中';

  @override
  String get rideActiveDescription => 'GPS 将沿城市路线记录您的位置。';

  @override
  String get gpsActive => 'GPS 信号正常';

  @override
  String get gpsLost => 'GPS 信号丢失';

  @override
  String get restoreGps => '恢复 GPS';

  @override
  String get time => '时间';

  @override
  String get distance => '距离';

  @override
  String get estimated => '预计';

  @override
  String distanceKm(String distance) {
    return '$distance 公里';
  }

  @override
  String get returnBike => '归还自行车';

  @override
  String get nearestReturnStation => '最近的还车站点';

  @override
  String get otherNearbyStations => '其他附近站点';

  @override
  String get phoneSafety => '请先安全停车，再使用手机或选择站点。';

  @override
  String get continueRide => '继续骑行';

  @override
  String get chooseReturnStation => '选择还车站点';

  @override
  String get chooseReturnStationDescription => '完成骑行需要一个空闲车桩。';

  @override
  String get withinReturnZone => '已在还车区内';

  @override
  String get confirmArrival => '确认到达';

  @override
  String get continueToDock => '继续前往车桩';

  @override
  String get scanStationQr => '扫描站点二维码';

  @override
  String get scanStationQrDescription => '扫描站点处的二维码海报，或输入站点代码，以验证归还。';

  @override
  String get cameraUnavailable => '相机不可用。请改为在下方输入站点代码。';

  @override
  String get stationCodeLabel => '站点代码';

  @override
  String get stationCodeHint => '例如 CENTRAL';

  @override
  String get confirm => '确认';

  @override
  String rideDeadlineCountdown(int minutes) {
    return '还需在 $minutes 分钟内归还自行车';
  }

  @override
  String get rideOverdueTitle => '骑行超时';

  @override
  String get rideOverdueBody =>
      '您已超过最长骑行时间。请立即归还自行车——若未及时归还，本次租车将以丢失结案并停用您的账号。';

  @override
  String extendRide(int count) {
    return '延长 60 分钟（剩余 $count 次）';
  }

  @override
  String get noExtensionsLeft => '已无可用的延长次数';

  @override
  String get secureBike => '停好自行车';

  @override
  String get secureBikeDescription => '将前轮推入空闲车桩，直到锁止。';

  @override
  String get confirmBikeDocked => '确认车辆已停入车桩';

  @override
  String get rideComplete => '骑行完成';

  @override
  String get rideCompleteDescription => '车辆已固定。请查看最终费用。';

  @override
  String get unlockFee => '解锁费';

  @override
  String startedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '计费 $count 分钟',
    );
    return '$_temp0';
  }

  @override
  String get rideDuration => '骑行时长';

  @override
  String get timeFare => '计时费';

  @override
  String hourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小时',
    );
    return '$_temp0';
  }

  @override
  String minuteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分钟',
    );
    return '$_temp0';
  }

  @override
  String get finalFare => '最终费用';

  @override
  String get holdReleased => '预授权已释放';

  @override
  String chargeAmount(String amount) {
    return '扣款 $amount';
  }

  @override
  String get ridePaid => '骑行费用已支付';

  @override
  String get paymentPending => '骑行已结束 · 待支付';

  @override
  String get holdReleasedDescription => '剩余测试预授权已释放。';

  @override
  String get paymentPendingDescription => '自行车已安全归还。请点击下方重试模拟扣款。';

  @override
  String get rideId => '骑行 ID';

  @override
  String get duration => '时长';

  @override
  String get returnedAt => '归还时间';

  @override
  String get retryPayment => '重试支付';

  @override
  String get retry => '重试';

  @override
  String get rentAnotherBike => '再租一辆';

  @override
  String get pleaseWait => '请稍候…';

  @override
  String get timeBasedPricing => '计时计费';

  @override
  String pricingFormula(String unlockFee, String minuteRate) {
    return '$unlockFee +（计费分钟数 × $minuteRate）';
  }

  @override
  String pricingExample(int minutes) {
    return '$minutes 分钟示例';
  }

  @override
  String get pricingTimerDescription => '计时器在车辆解锁后启动，车桩确认归还后停止。';

  @override
  String get choosePaymentMethod => '选择付款方式';

  @override
  String get personalCard => '个人银行卡';

  @override
  String get travelCard => '交通卡';

  @override
  String get addCardFuture => '添加新卡片的功能将在未来的用户模块中提供。';

  @override
  String get paypalSandbox => '测试支付';

  @override
  String get paypalSandboxDescription => '本地模拟 · 不涉及真实资金';

  @override
  String get paypalAccountSubtitle => 'PayPal 沙盒账户';

  @override
  String get paypalCheckoutTitle => 'PayPal 付款';

  @override
  String get paypalCheckoutSemantics => '安全的 PayPal 付款确认页';

  @override
  String get selected => '已选择';

  @override
  String get selectable => '可选择';

  @override
  String get cityMapSemantics => '城市地图，显示当前车辆位置与还车站点';

  @override
  String get errorInvalidQr => '这个二维码不是 BikeRent 车辆。请扫描车身上的二维码。';

  @override
  String errorBikeReserved(String bikeId) {
    return '自行车 $bikeId 已被预约。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeMaintenance(String bikeId) {
    return '自行车 $bikeId 正在维护中，无法租用。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeUnavailable(String bikeId) {
    return '自行车 $bikeId 目前不可用，无法租用。请选择其他车辆并重新扫描。';
  }

  @override
  String errorBikeLowBattery(String bikeId, int percent) {
    return '自行车 $bikeId 电量过低（$percent%），无法租用。最低要求为 10%。请选择其他车辆并重新扫描。';
  }

  @override
  String get lowBatteryWarningTitle => '电量不足警告';

  @override
  String lowBatteryWarningMessage(String bikeId, int percent) {
    return '自行车 $bikeId 电量仅剩 $percent%。骑行距离和电机助力可能受限。要继续吗？';
  }

  @override
  String get continueButton => '继续';

  @override
  String get bikeCannotBeRentedTitle => '无法租用此自行车';

  @override
  String errorHoldDeclined(String amount) {
    return '$amount 测试预授权被拒绝。准备好后可重试。';
  }

  @override
  String get errorPaymentConfiguration => '本地测试付款模拟器不可用。';

  @override
  String get errorPaymentNetwork => '本地测试付款失败。准备好后可重试。';

  @override
  String get errorPaymentCancelled => '测试付款确认已被取消。准备好后可重试。';

  @override
  String get errorPaymentAuthorizationFailed => '测试付款无法完成预授权。准备好后可重试。';

  @override
  String get errorPaymentCaptureFailed => '测试付款无法扣取骑行费用。付款仍处于待处理状态，请在下方重试。';

  @override
  String get errorLockFailed => '车锁没有响应。请靠近车辆后重试。';

  @override
  String get errorGpsLost => 'GPS 信号丢失。请移至开阔区域并检查位置权限。';

  @override
  String errorStationFull(String station) {
    return '$station 没有空闲车桩。请选择其他站点。';
  }

  @override
  String get errorChooseStation => '请先选择还车站点。';

  @override
  String get errorOutsideReturnZone => '归还前请移动到所选站点 250 米范围内。';

  @override
  String get errorStationQrMismatch => '该二维码与所选站点不符。请扫描站点处的二维码海报或输入站点代码。';

  @override
  String get errorMaxExtensionsReached => '延长次数已用完。请归还自行车以结束本次租车。';

  @override
  String get errorLocationPermissionDenied => '需要位置权限才能验证归还。请开启后重试。';

  @override
  String get errorAccountSuspended => '账号已停用：您有一辆自行车未归还。请联系客服以恢复。';

  @override
  String get errorDockNotDetected => '未检测到车桩。请将自行车用力推入车桩后重试。';

  @override
  String get errorAuthenticationFailed => '演示骑手登录失败。请检查 Supabase 后重试。';

  @override
  String get errorBackendConnection => '租车服务不可用。请检查网络连接后重试。';

  @override
  String get errorActiveRentalExists => '该骑手还有未完成的租车。请先继续或完成。';

  @override
  String errorStationMaintenance(String station) {
    return '站点 $station 正在维护中，无法在此租车或还车。';
  }

  @override
  String errorStationTerminated(String station) {
    return '站点 $station 已终止，无法在此租车或还车。';
  }

  @override
  String get errorStationMaintenanceGeneral => '该站点正在维护中，无法在此租车或还车。';

  @override
  String get errorStationTerminatedGeneral => '该站点已终止，无法在此租车或还车。';

  @override
  String get stationUnderMaintenance => '维护中';

  @override
  String get stationCannotReturnMaintenance => '该站点正在维护中，无法在此归还自行车。';

  @override
  String get errorInvalidRentalTransition => '服务器上的租车状态已变更。请重试以恢复。';

  @override
  String get rideWarningDepositExceededTitle => '超出押金时限';

  @override
  String get rideWarningDepositExceededBody => '您借用自行车的时间已超过押金时限，将产生额外租车费用。';

  @override
  String get rideWarningLegalActionTitle => '法律行动警告';

  @override
  String get rideWarningLegalActionBody =>
      '租赁时长已超过押金时限的 2 倍。若不及时归还自行车，将立即采取法律行动。';

  @override
  String get rideWarningSuspiciousActivityTitle => '检测到可疑活动';

  @override
  String get rideWarningSuspiciousActivityBody => '检测到可疑活动：您距离取车站点异常遥远。';

  @override
  String get rideWarningSuspiciousLegalTitle => '可疑活动与法律行动';

  @override
  String get rideWarningSuspiciousLegalBody =>
      '检测到远离站点的可疑活动，且已超出押金时限。若未归还自行车，将立即采取法律行动。';

  @override
  String get addBike => '添加车辆';

  @override
  String get editBike => '编辑车辆';

  @override
  String get bikeDetail => '车辆详情';

  @override
  String get bikeReport => '车辆报告';

  @override
  String get transferBike => '转移车辆';

  @override
  String get serviceBike => '检修车辆';

  @override
  String get reportDetail => '报告详情';

  @override
  String get pendingReports => '待处理报告';

  @override
  String get newReport => '新报告';

  @override
  String get pendingReportDetails => '待处理报告详情';

  @override
  String get paymentMethods => '付款方式';

  @override
  String get conditionReports => '车况报告';

  @override
  String get reviewAndResolveBikeIssues => '审核并处理车辆问题。';

  @override
  String get trackSubmittedBikeReports => '追踪您提交的车辆报告。';

  @override
  String get searchReportOrBikeId => '搜索报告或车辆 ID';

  @override
  String get pending => '待处理';

  @override
  String get approved => '已通过';

  @override
  String get rejected => '已拒绝';

  @override
  String get cancelled => '已取消';

  @override
  String get reports => '报告';

  @override
  String get newestFirst => '最新优先';

  @override
  String get cancelReport => '取消报告';

  @override
  String get cancelReportQuestion => '取消报告？';

  @override
  String get keepReport => '保留报告';

  @override
  String cancelReportConfirmation(String reportId) {
    return '取消 $reportId？该报告将不再由管理员审核。';
  }

  @override
  String reportCancelled(String reportId) {
    return '已取消 $reportId。';
  }

  @override
  String failedToCancelReport(String error) {
    return '取消报告失败：$error';
  }

  @override
  String get onlyPendingReportsCanBeCancelled => '只有待处理的报告可以取消。';

  @override
  String allReports(int count) {
    return '全部 $count';
  }

  @override
  String pendingReportsCount(int count) {
    return '待处理 $count';
  }

  @override
  String approvedReportsCount(int count) {
    return '已通过 $count';
  }

  @override
  String rejectedReportsCount(int count) {
    return '已拒绝 $count';
  }

  @override
  String cancelledReportsCount(int count) {
    return '已取消 $count';
  }

  @override
  String get noMatchingReports => '没有匹配的报告';

  @override
  String get noReportsYet => '暂无报告';

  @override
  String get tryDifferentSearchTerm => '请尝试其他搜索关键词。';

  @override
  String get bikeConditionReportsAppearHere => '车况报告将显示在这里。';

  @override
  String get reported => '已报告';

  @override
  String get unableToLoadReports => '无法加载报告';

  @override
  String get brakeSystem => '刹车系统';

  @override
  String get tyres => '轮胎';

  @override
  String get chainAndGears => '链条与变速';

  @override
  String get seatAndFrame => '车座与车架';

  @override
  String get bellAndLights => '车铃与车灯';

  @override
  String get qrLock => '二维码 / 车锁';

  @override
  String get other => '其他';

  @override
  String get unableToLoadReport => '无法加载报告';

  @override
  String get reportNotFound => '未找到报告';

  @override
  String get reportDetails => '报告详情';

  @override
  String get noStationAssigned => '未分配站点';

  @override
  String get reportInformation => '报告信息';

  @override
  String get problem => '问题';

  @override
  String get reportIdLabel => '报告 ID';

  @override
  String get photo => '照片';

  @override
  String get photoUnavailable => '照片不可用';

  @override
  String get photoCouldNotBeLoaded => '报告照片无法加载。';

  @override
  String get unableToDisplayPhoto => '无法显示照片';

  @override
  String get attachedPhotoCouldNotBeDisplayed => '附加照片无法显示。';

  @override
  String get noPhotoAttached => '未附照片';

  @override
  String get reportWithoutPhoto => '此报告提交时未附照片。';

  @override
  String get issueDescription => '问题描述';

  @override
  String get pendingReview => '待审核';

  @override
  String get pendingReviewDescription => '此报告尚未审核。';

  @override
  String get reportApproved => '报告已通过';

  @override
  String get reportRejected => '报告已拒绝';

  @override
  String get reviewed => '已审核';

  @override
  String get reviewNote => '审核备注';

  @override
  String get noReviewNoteProvided => '未提供审核备注。';

  @override
  String get reportCancelledStatus => '报告已取消';

  @override
  String get reportCancelledDescription => '您在审核前取消了此报告。';

  @override
  String get addNewBike => '添加新车辆';

  @override
  String get step1BasicInformation => '第 1 步（共 3 步）• 基本信息';

  @override
  String get step2QrCode => '第 2 步（共 3 步）• 二维码';

  @override
  String get step3ReviewInformation => '第 3 步（共 3 步）• 核对信息';

  @override
  String get bikeCode => '车辆代码';

  @override
  String get enterBikeCode => '输入车辆代码';

  @override
  String get bikeCodeTooShort => '车辆代码过短';

  @override
  String get initialStation => '初始站点';

  @override
  String get pleaseSelectStation => '请选择站点';

  @override
  String get selectStation => '选择站点';

  @override
  String get unableToLoadStations => '无法加载站点';

  @override
  String get noStationsAvailable => '暂无可用站点。';

  @override
  String get noStationSelected => '未选择站点';

  @override
  String get batteryPercentage => '电量百分比';

  @override
  String get enterBatteryPercentage => '输入电量百分比';

  @override
  String get invalidBatteryPercentage => '电量百分比无效';

  @override
  String get enterValidNumber => '请输入有效数字';

  @override
  String get batteryRangeError => '电量必须在 0 到 100 之间';

  @override
  String get battery => '电量';

  @override
  String get initialStatus => '初始状态';

  @override
  String get status => '状态';

  @override
  String get available => '可用';

  @override
  String get maintenance => '维护中';

  @override
  String get retired => '已退役';

  @override
  String get qrGeneratedAutomatically => '系统将自动生成唯一的二维码令牌。';

  @override
  String get qrScanningDescription => '二维码之后可包含此令牌，供扫描车辆时使用。';

  @override
  String get bikeQrCode => '车辆二维码';

  @override
  String get qrTokenIdentifiesBike => '扫描时将使用以下令牌识别此车辆。';

  @override
  String get qrToken => 'QR 令牌';

  @override
  String get qrTokenNotGenerated => '二维码令牌尚未生成';

  @override
  String get notGenerated => '未生成';

  @override
  String get qrPlaceholderDescription => '当前的二维码图片仅为占位图。之后我们可以根据该令牌生成实际的二维码。';

  @override
  String get generatedQrCode => '已生成的二维码';

  @override
  String get next => '下一步';

  @override
  String get bikeInformation => '车辆信息';

  @override
  String get notSelected => '未选择';

  @override
  String get bikeAddedSuccessfully => '车辆添加成功';

  @override
  String failedToAddBike(String error) {
    return '添加车辆失败：$error';
  }

  @override
  String get managePaymentMethodsSubtitle => '管理银行卡与 PayPal';

  @override
  String get termsOfService => '服务条款';

  @override
  String get termsOfServiceSubtitle => '租赁规则、安全政策与责任条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyPolicySubtitle => '数据保护、GPS 定位与隐私权利';

  @override
  String get logOut => '退出登录';

  @override
  String get onlineCheckout => '在线结账';

  @override
  String get savedCards => '已保存的卡片';

  @override
  String savedCardsCount(int count) {
    return '已保存 $count 张';
  }

  @override
  String get noCardsSaved => '还没有保存的卡片';

  @override
  String get noCardsSavedDescription => '添加 Visa 或 Mastercard，即可快速便捷地一键租车。';

  @override
  String get addCard => '添加卡片';

  @override
  String get removeCard => '移除卡片';

  @override
  String removeCardConfirmation(String brand, String lastFour) {
    return '确定要移除尾号为 $lastFour 的 $brand 卡片吗？';
  }

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get cardRemovedSuccess => '卡片移除成功';

  @override
  String get failedToRemoveCard => '卡片移除失败';

  @override
  String cardSetAsDefault(String brand) {
    return '$brand 已设为默认付款方式';
  }

  @override
  String get failedToUpdateDefaultCard => '更新默认卡片失败';

  @override
  String get editCard => '编辑卡片';

  @override
  String get cardUpdatedSuccess => '卡片更新成功';

  @override
  String get failedToUpdateCard => '卡片更新失败';

  @override
  String get cardAddedSuccess => '卡片添加成功';

  @override
  String get failedToAddCard => '卡片添加失败';

  @override
  String get cardNumber => '卡号';

  @override
  String get cardNumberHint => '4xxx xxxx xxxx xxxx';

  @override
  String get cardholderName => '持卡人姓名';

  @override
  String get cardholderNameHint => '例如：张三';

  @override
  String get expiryDate => '有效期';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get cvvCvc => 'CVV / CVC';

  @override
  String get cvvHint => '•••';

  @override
  String get setAsDefaultPaymentMethod => '设为默认付款方式';

  @override
  String get automaticallyUseCard => '租车时自动使用此卡';

  @override
  String get updateCard => '更新卡片';

  @override
  String cardExpiry(String month, String year) {
    return '$month/$year 到期';
  }

  @override
  String get activeCard => '启用中的卡片';

  @override
  String get defaultBadge => '默认';

  @override
  String get cardOptions => '卡片选项';

  @override
  String get setAsDefault => '设为默认';

  @override
  String get editCardMenu => '编辑卡片';

  @override
  String get removeCardMenu => '移除卡片';

  @override
  String get payPal => 'PayPal';

  @override
  String get payPalBuiltIn => '内置';

  @override
  String get payPalSubtitle => 'WebView 结账 · 始终可用';

  @override
  String get payPalInformation => 'PayPal 信息';

  @override
  String get payPalIntegration => 'PayPal 集成';

  @override
  String get payPalAlwaysAvailable => '始终可用的付款方式';

  @override
  String get payPalDescription =>
      'PayPal 结账通过应用内安全的 WebView 在租车授权时按需处理。它无需保存信用卡或借记卡信息，因此无法编辑或移除。';

  @override
  String get gotIt => '知道了';

  @override
  String get cardholderPreview => '持卡人';

  @override
  String get cardholderNamePreview => '持卡人姓名';

  @override
  String get expiresPreview => '有效期至';

  @override
  String get agree => '同意';

  @override
  String get agreementConfirmation => '协议确认';

  @override
  String agreementNotice(String buttonText, String title) {
    return '点击上方或下方的“$buttonText”，即表示您已阅读并接受这些$title。';
  }

  @override
  String agreeAndContinue(String buttonText) {
    return '$buttonText并继续';
  }

  @override
  String get contactSupport => '有疑问？请联系 support@bikerent.app';

  @override
  String errorLoadingStations(String error) {
    return '加载站点失败：$error';
  }

  @override
  String get stationA => '站点 A';

  @override
  String get stationB => '站点 B';

  @override
  String get selectOriginStation => '选择起点站点';

  @override
  String get selectDestinationStation => '选择终点站点';

  @override
  String get underMaintenance => '维护中';

  @override
  String get selectedStationTooFar => '所选站点距离过远';

  @override
  String get etaLabel => '预计到达：';

  @override
  String get estimatedArrivalTime => '预计到达时间（ETA）';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String totalDistanceKm(String distance) {
    return '总距离：$distance 公里';
  }

  @override
  String get selectStationsToCalculateRoutePrompt => '请选择站点 A 和站点 B 以计算路线。';

  @override
  String failedToLoadBikes(String error) {
    return '加载车辆失败：$error';
  }

  @override
  String get invalidBikeIdError => '无法打开：车辆 ID 无效';

  @override
  String get stationBikes => '站点车辆';

  @override
  String get locationCoordinatesNotProvided => '未提供位置坐标';

  @override
  String get searchBikesCodeOrId => '按代码或 ID 搜索车辆';

  @override
  String get noBikesInStationYet => '该站点还没有自行车';

  @override
  String get noBikesMatchSearch => '没有符合搜索条件的车辆。';

  @override
  String get unknownStatus => '未知';

  @override
  String bikeStatus(String status) {
    return '状态：$status';
  }

  @override
  String failedToLoadStations(String error) {
    return '加载站点失败：$error';
  }

  @override
  String get searchStationHint => '搜索站点代码、名称或地址…';

  @override
  String get longPressMapToAddStation => '长按地图添加新站点';

  @override
  String get noMatchingStationsFound => '未找到匹配的站点。';

  @override
  String get unnamedStation => '未命名站点';

  @override
  String get noAddress => '无地址';

  @override
  String get stationNameEmptyError => '站点名称不能为空。';

  @override
  String get stationAddressEmptyError => '站点地址不能为空。';

  @override
  String get validCapacityError => '请输入有效的最大容量数字。';

  @override
  String maxCapacityExceededError(int capacity, int bikes) {
    return '最大容量（$capacity）不能少于当前停放的车辆数（$bikes）。';
  }

  @override
  String get stationUpdatedSuccess => '站点更新成功！';

  @override
  String get stationAddedSuccess => '站点添加成功！';

  @override
  String failedToSaveStation(String error) {
    return '保存站点失败：$error';
  }

  @override
  String get removeStation => '移除站点';

  @override
  String get confirmRemoveStationBody => '确定要移除此站点吗？';

  @override
  String get stationRemovedSuccess => '站点移除成功！';

  @override
  String failedToRemoveStation(String error) {
    return '移除站点失败：$error';
  }

  @override
  String get changePhoto => '更换照片';

  @override
  String get stationName => '站点名称';

  @override
  String get enterStationNameHint => '输入站点名称…';

  @override
  String get stationCode => '站点代码';

  @override
  String get readOnly => '只读';

  @override
  String get address => '地址';

  @override
  String get enterStationAddressHint => '输入站点地址…';

  @override
  String get operatingStatus => '运营状态';

  @override
  String get currentDockedBikes => '当前停放车辆数';

  @override
  String get maxBikesPerStation => '每站最大车辆数';

  @override
  String get addStation => '添加站点';

  @override
  String get updateStation => '更新站点';

  @override
  String get viewBikesAtStation => '查看站点车辆';

  @override
  String get noAddressSet => '未设置地址';

  @override
  String get noBikesAtStation => '此站点暂无车辆。';

  @override
  String stationDeactivatedSuccess(String stationName) {
    return '$stationName 已成功停用';
  }

  @override
  String get searchStationToRemove => '搜索要移除的站点…';

  @override
  String get searchStationNameOrAddress => '搜索站点名称或地址…';

  @override
  String get noStationsFound => '未找到站点。';

  @override
  String bikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 辆自行车',
    );
    return '$_temp0';
  }

  @override
  String get currentlySelected => '当前已选择';

  @override
  String get targetStationToRemove => '要移除的目标站点';

  @override
  String get closestToYou => '离您最近';

  @override
  String get reset => '重置';

  @override
  String get allActiveStations => '所有运营中的站点';

  @override
  String get nearbyStations => '附近站点';

  @override
  String stationSummarySubtitle(String address, int count, String distance) {
    return '$address • $count 辆自行车$distance';
  }

  @override
  String confirmRemoveStationTitle(String stationName) {
    return '确定要移除\n$stationName 吗？';
  }

  @override
  String get actionIrreversibleWarning => '此操作不可撤销，确定要继续吗？';

  @override
  String get removeLocation => '移除位置';

  @override
  String get okButton => '确定';

  @override
  String get scanningLabel => '正在扫描…';

  @override
  String get flashlightTooltip => '手电筒';

  @override
  String get invalidQrTitle => '无效的二维码';

  @override
  String reservationExpiresIn(String time) {
    return '预约将在 $time 后过期';
  }

  @override
  String get rentalTimedOutTitle => '租车超时';

  @override
  String rentalTimedOutBody(int minutes) {
    return '您的自行车预约已超过 $minutes 分钟时限，车辆已被释放。';
  }

  @override
  String get forceEndedTitle => '管理员已结束本次租车';

  @override
  String get rentalEndedTitle => '租车已结束';

  @override
  String get rentalEndedBody => '您的租车已结束。随时可以开始新的骑行。';

  @override
  String returnAtStation(String station) {
    return '在 $station 归还';
  }

  @override
  String get originStation => '起点站点';

  @override
  String get tripStartedHere => '行程由此开始';

  @override
  String get currentLocation => '当前位置';

  @override
  String get yourGpsPosition => '您的 GPS 位置';

  @override
  String get stationDetailsTooltip => '站点详情';

  @override
  String get addPaymentMethod => '添加付款方式';

  @override
  String get lowBatteryFallbackBike => '这辆自行车';

  @override
  String get errorStationFullGeneral => '附近站点目前没有空闲车桩，请稍后再试。';

  @override
  String get termsNoticePrefix => '继续进行租车流程，即视为您已阅读并接受本应用的';

  @override
  String get termsNoticeMiddle => '和';

  @override
  String get termsNoticeSuffix => '。';

  @override
  String get rideHistoryLoadFailed => '无法加载骑行记录。';

  @override
  String get noCompletedRides => '还没有已完成的骑行。';

  @override
  String get weatherConnectionFailedTitle => '连接失败';

  @override
  String get weatherConnectionFailedBody => '无法连接天气服务。请检查网络连接后重试。';

  @override
  String get weatherTimeoutTitle => '连接超时';

  @override
  String get weatherTimeoutBody => '天气服务响应时间过长。请检查网络连接后重试。';

  @override
  String get weatherRateLimitTitle => '已达请求上限';

  @override
  String get weatherRateLimitBody => '天气服务暂时繁忙。请稍候片刻后重试。';

  @override
  String get weatherLocationTitle => '位置不可用';

  @override
  String get weatherLocationBody => '需要位置权限才能显示当前天气。请开启 GPS 并授予权限。';

  @override
  String get weatherOutsideMalaysiaTitle => '超出服务范围';

  @override
  String get weatherOutsideMalaysiaBody => '天气预报仅限马来西亚境内的位置可用。';

  @override
  String get weatherServiceTitle => '服务不可用';

  @override
  String get weatherServiceBody => '天气服务暂时不可用。请稍后重试。';

  @override
  String get weatherNotFoundTitle => '天气不可用';

  @override
  String get weatherNotFoundBody => '未找到该位置的天气预报。';

  @override
  String get weatherGenericTitle => '天气不可用';

  @override
  String get weatherGenericBody => '目前无法加载骑行条件。请重试。';

  @override
  String get aqiModerate => '中等';

  @override
  String get aqiUnhealthy => '不健康';

  @override
  String get aqiVeryUnhealthy => '非常不健康';

  @override
  String get aqiHazardous => '危险';

  @override
  String get rideConditionsRateLimitSemantics => '骑行条件。已达请求上限。';

  @override
  String rideConditionsErrorSemantics(String title, String message) {
    return '骑行条件。$title：$message。';
  }

  @override
  String get pmSessionExpired => '登录已过期，请重新登录。';

  @override
  String get pmCardInUse => '无法删除卡片：该卡片已关联进行中或待处理的租车。';

  @override
  String get pmDuplicateCard => '此卡片已添加到您的账户。';

  @override
  String pmValidationError(String detail) {
    return '验证错误：$detail';
  }

  @override
  String get pmUnknownError => '发生意外错误，请重试。';

  @override
  String get cvCardNumberRequired => '请输入卡号';

  @override
  String get cvCardDigitsOnly => '请输入有效的卡号数字';

  @override
  String get cvCardBrandUnsupported => '仅支持 Visa 和 Mastercard';

  @override
  String cvCardNumberLength(int entered) {
    return '卡号必须为 16 位（已输入 $entered/16）';
  }

  @override
  String get cvCardNumberTooLong => '卡号不能超过 16 位';

  @override
  String get cvCardChecksumFailed => '卡号无效（校验失败）';

  @override
  String get cvExpiryRequired => '请输入有效期';

  @override
  String get cvExpiryFormat => '有效期请按 MM/YY 格式输入';

  @override
  String get cvExpiryInvalidMonth => '月份无效（应为 01–12）';

  @override
  String get cvExpiryInvalidYear => '有效期年份无效';

  @override
  String get cvCardExpired => '卡片已过期';

  @override
  String get cvExpiryTooFar => '有效期年份过远';

  @override
  String get cvCvvRequired => '请输入 CVV 码';

  @override
  String get cvCvvLength => 'CVV 码必须为 3 位';

  @override
  String get cvNameRequired => '请输入持卡人姓名';

  @override
  String get cvNameTooShort => '姓名至少需要 2 个字符';

  @override
  String get cvNameTooLong => '姓名不能超过 50 个字符';

  @override
  String get cvNameInvalidChars => '仅支持字母、空格、连字符和点号';

  @override
  String get cvNameNeedsTwoParts => '请输入名字和姓氏';

  @override
  String get cvNameDuplicate => '持卡人姓名已被其他卡片使用';

  @override
  String get verificationRequiredTitle => '需要身份验证';

  @override
  String get verificationRequiredBody => '租借车辆前，请先添加身份证号并完成人脸识别验证。';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => 'BikeRent';

  @override
  String get home => '首頁';

  @override
  String get stations => '站點';

  @override
  String get bikeSession => '騎乘';

  @override
  String get scan => '掃描';

  @override
  String get history => '紀錄';

  @override
  String get profile => '個人';

  @override
  String get adminManagement => '管理員管理';

  @override
  String get bikeManagement => '車輛管理';

  @override
  String get settings => '設定';

  @override
  String get back => '返回';

  @override
  String get scanQrCode => '掃描 QR 碼';

  @override
  String get currentRide => '目前騎乘';

  @override
  String get rideInProgress => '騎乘進行中。';

  @override
  String get stationsDescription => '站點車柱容量、附近站點與還車地點。';

  @override
  String get rideHistory => '騎乘紀錄';

  @override
  String get rideHistoryDescription => '檢視過往騎乘、車資與歸還站點。';

  @override
  String get rideDetails => '騎乘詳細資訊';

  @override
  String get pastRides => '過往騎乘';

  @override
  String get totalRides => '騎乘總次數';

  @override
  String get totalDistance => '總距離';

  @override
  String get totalSpent => '總花費';

  @override
  String rideHistoryEntrySemantics(
    String date,
    String time,
    String fromStation,
    String toStation,
    String duration,
    String distance,
    String fare,
  ) {
    return '$date $time 的騎乘，從 $fromStation 到 $toStation，時長 $duration，距離 $distance，車資 $fare。輕觸以檢視詳細資訊。';
  }

  @override
  String get rideCompleted => '騎乘完成';

  @override
  String get journeyDetails => '行程詳細資訊';

  @override
  String get from => '起點';

  @override
  String get to => '終點';

  @override
  String departedAt(String time) {
    return '於 $time 出發';
  }

  @override
  String arrivedAt(String time) {
    return '於 $time 抵達';
  }

  @override
  String get rideSummary => '騎乘摘要';

  @override
  String get bikeId => '車輛 ID';

  @override
  String get paymentDetails => '付款詳細資訊';

  @override
  String get depositHeld => '已凍結押金';

  @override
  String get rideFareFromDeposit => '騎乘費用已自押金扣除';

  @override
  String get depositRefunded => '剩餘押金已退還';

  @override
  String get totalPaid => '已付總額';

  @override
  String get depositRefund => '押金退款';

  @override
  String get paymentMethod => '付款方式';

  @override
  String get depositPaymentExplanation => '騎乘費用已自押金扣除，剩餘押金將退回原付款方式。';

  @override
  String get profileDescription => '個人資料、錢包、權限與騎乘紀錄。';

  @override
  String get fleetDescription => '車隊健康狀況、電量狀態與維護佇列。';

  @override
  String get adminDescription => '管理站點、車輛與使用者。';

  @override
  String get stationManagement => '站點管理';

  @override
  String get stationManagementDescription => '站點、車柱容量與還車地點';

  @override
  String get bikeManagementDescription => '車隊健康、電量狀態與維護';

  @override
  String get userManagement => '使用者管理';

  @override
  String get userManagementDescription => '使用者資料、錢包、權限與騎乘紀錄';

  @override
  String get appSettings => '應用程式設定';

  @override
  String get appSettingsDescription => '管理外觀與騎乘權限。';

  @override
  String get language => '語言';

  @override
  String get languageDescription => '選擇偏好的應用程式語言';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get english => '英語';

  @override
  String get malay => '馬來語';

  @override
  String get simplifiedChinese => '簡體中文';

  @override
  String get traditionalChinese => '繁體中文';

  @override
  String get darkTheme => '深色主題';

  @override
  String get on => '開啟';

  @override
  String get off => '關閉';

  @override
  String get locationAccess => '位置權限';

  @override
  String get locationAccessDescription => '騎乘進行期間需要';

  @override
  String get rideNotifications => '騎乘通知';

  @override
  String get rideNotificationsDescription => '還車提醒與付款更新';

  @override
  String get goodAfternoon => '下午好';

  @override
  String get readyToRide => '準備好騎乘了嗎？';

  @override
  String bikeAvailability(int bikeCount, int stationCount) {
    return '$bikeCount 輛自行車分布於 $stationCount 個站點。';
  }

  @override
  String unlockRate(String unlockFee, String minuteRate) {
    return '$unlockFee 解鎖費 + 每計費分鐘 $minuteRate';
  }

  @override
  String get scanBike => '掃描車輛';

  @override
  String get findStation => '尋找站點';

  @override
  String get returnStationUnavailable => '目前沒有可用的還車站點。';

  @override
  String get liveNetwork => '即時網路';

  @override
  String get bikes => '車輛';

  @override
  String get openDocks => '空閒車柱';

  @override
  String get nearYou => '附近';

  @override
  String get viewAll => '檢視全部';

  @override
  String stationDistance(int distance) {
    return '距離 $distance 公尺';
  }

  @override
  String bikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 輛自行車',
    );
    return '$_temp0';
  }

  @override
  String dockCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個車柱',
    );
    return '$_temp0';
  }

  @override
  String docksAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個空閒車柱',
    );
    return '$_temp0';
  }

  @override
  String get full => '已滿';

  @override
  String get libraryStation => '圖書館站';

  @override
  String get mainGate => '正門站';

  @override
  String get centralStation => '中央站';

  @override
  String get riversidePark => '河濱公園站';

  @override
  String get marketSquare => '市場廣場站';

  @override
  String get universityGate => '大學門站';

  @override
  String get rideConditions => '騎乘條件';

  @override
  String get currentWeather => '目前天氣';

  @override
  String get partlyCloudy => '局部多雲';

  @override
  String feelsLike(String temperature) {
    return '體感 $temperature';
  }

  @override
  String get scatteredThunderstorms => '局部雷陣雨';

  @override
  String rainChance(int chance) {
    return '降雨機率 $chance%';
  }

  @override
  String get humidity => '濕度';

  @override
  String get airQuality => '空氣品質';

  @override
  String get good => '良好';

  @override
  String get wind => '風力';

  @override
  String nextHour(String condition) {
    return '未來一小時 · $condition';
  }

  @override
  String weatherValues(String temperature, String rainChance) {
    return '$temperature · $rainChance';
  }

  @override
  String weatherUpdated(String time, String date) {
    return '更新於 $time · $date';
  }

  @override
  String rideConditionsSemantics(
    String location,
    String condition,
    String temperature,
    String feelsLike,
    String nextCondition,
    String nextTemperature,
    String rainChance,
    String humidity,
    String airQualityIndex,
    String airQualityLabel,
    String wind,
  ) {
    return '騎乘條件。目前位置：$location。目前天氣：$condition，$temperature，體感 $feelsLike。未來一小時：$nextCondition，$nextTemperature，$rainChance。濕度 $humidity。空氣品質指標 $airQualityIndex，$airQualityLabel。風力 $wind。';
  }

  @override
  String get scanStep => '掃描';

  @override
  String get rideStep => '騎乘';

  @override
  String get returnStep => '歸還';

  @override
  String get payStep => '付款';

  @override
  String stepSemantics(String label) {
    return '$label步驟';
  }

  @override
  String get cameraPreviewSemantics => '相機預覽。輕觸以掃描車身 QR 碼。';

  @override
  String get cameraReady => '相機已就緒';

  @override
  String get cameraNoPermission => '無權限';

  @override
  String get cameraPermissionDescription => '需要相機權限才能掃描車身 QR 碼。請輕觸下方以允許存取。';

  @override
  String get grantPermission => '授予權限';

  @override
  String get cameraPermissionSettingsPrompt => '需要相機權限。請在裝置設定中開啟相機。';

  @override
  String get pointCamera => '將相機對準車身上的 QR 碼';

  @override
  String get scanInstructions => '掃描車身上的 QR 碼即可開始騎乘';

  @override
  String get bikeReady => '車輛已就緒';

  @override
  String get bikeReadyDescription => '執行測試預授權前，請先確認車輛與車資。';

  @override
  String bikeBatteryLocation(int battery, String location) {
    return '電量 $battery% · $location';
  }

  @override
  String get view => '檢視';

  @override
  String get brakesSafe => '煞車與輪胎狀況良好';

  @override
  String brakesIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '煞車 / 輪胎：已回報 $count 個問題',
    );
    return '$_temp0';
  }

  @override
  String get frameSafe => '座墊與車架無明顯損壞';

  @override
  String frameIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '座墊 / 車架：已回報 $count 個問題',
    );
    return '$_temp0';
  }

  @override
  String get lightsSafe => '前後車燈正常';

  @override
  String lightsIssueReported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '車燈 / 車鈴：已回報 $count 個問題',
    );
    return '$_temp0';
  }

  @override
  String get checkingBikeCondition => '正在檢查車況回報…';

  @override
  String get reportBikeIssue => '回報車輛問題';

  @override
  String get change => '變更';

  @override
  String reviewHold(String amount) {
    return '確認 $amount 預授權';
  }

  @override
  String get cancelRental => '取消租借';

  @override
  String get holdExplanation => '預授權並非實際扣款，未使用的金額會在還車後釋放。';

  @override
  String get authorizeCardHold => '執行測試預授權';

  @override
  String get authorizeCardHoldDescription => '於自行車解鎖前模擬測試付款的授權。';

  @override
  String get temporaryAuthorizationHold => '暫時預授權';

  @override
  String authorizeHold(String amount) {
    return '執行 $amount 預授權';
  }

  @override
  String get unlockBikeTitle => '解鎖自行車';

  @override
  String unlockBikeDescription(String bikeId) {
    return '後鎖開啟時請留在 $bikeId 旁。';
  }

  @override
  String get contactingBikeLock => '正在連線車鎖…';

  @override
  String get cardHoldAuthorized => '測試預授權已確認';

  @override
  String get unlockBike => '解鎖車輛';

  @override
  String get rideActive => '騎乘進行中';

  @override
  String get rideActiveDescription => 'GPS 會沿城市路線記錄您的位置。';

  @override
  String get gpsActive => 'GPS 訊號正常';

  @override
  String get gpsLost => 'GPS 訊號遺失';

  @override
  String get restoreGps => '恢復 GPS';

  @override
  String get time => '時間';

  @override
  String get distance => '距離';

  @override
  String get estimated => '預估';

  @override
  String distanceKm(String distance) {
    return '$distance 公里';
  }

  @override
  String get returnBike => '歸還自行車';

  @override
  String get nearestReturnStation => '最近的還車站點';

  @override
  String get otherNearbyStations => '其他附近站點';

  @override
  String get phoneSafety => '請先安全停車，再使用手機或選擇站點。';

  @override
  String get continueRide => '繼續騎乘';

  @override
  String get chooseReturnStation => '選擇還車站點';

  @override
  String get chooseReturnStationDescription => '完成騎乘需要一個空柱。';

  @override
  String get withinReturnZone => '已在還車區內';

  @override
  String get confirmArrival => '確認抵達';

  @override
  String get continueToDock => '繼續前往車柱';

  @override
  String get scanStationQr => '掃描站點 QR 碼';

  @override
  String get scanStationQrDescription => '掃描站點的 QR 碼海報，或輸入站點代碼，以驗證歸還。';

  @override
  String get cameraUnavailable => '相機無法使用。請改為在下方輸入站點代碼。';

  @override
  String get stationCodeLabel => '站點代碼';

  @override
  String get stationCodeHint => '例如 CENTRAL';

  @override
  String get confirm => '確認';

  @override
  String rideDeadlineCountdown(int minutes) {
    return '還需在 $minutes 分鐘內歸還自行車';
  }

  @override
  String get rideOverdueTitle => '騎乘逾期';

  @override
  String get rideOverdueBody =>
      '您已超過最長騎乘時間。請立即歸還自行車——若未準時歸還，本次租借將以遺失結案並停用您的帳號。';

  @override
  String extendRide(int count) {
    return '延長 60 分鐘（剩餘 $count 次）';
  }

  @override
  String get noExtensionsLeft => '已無可用的延長次數';

  @override
  String get secureBike => '停妥自行車';

  @override
  String get secureBikeDescription => '將前輪推入空柱，直到卡緊上鎖。';

  @override
  String get confirmBikeDocked => '確認車輛已停入車柱';

  @override
  String get rideComplete => '騎乘完成';

  @override
  String get rideCompleteDescription => '車輛已固定。請確認最終費用。';

  @override
  String get unlockFee => '解鎖費';

  @override
  String startedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '計費 $count 分鐘',
    );
    return '$_temp0';
  }

  @override
  String get rideDuration => '騎乘時長';

  @override
  String get timeFare => '計時費';

  @override
  String hourCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 小時',
    );
    return '$_temp0';
  }

  @override
  String minuteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 分鐘',
    );
    return '$_temp0';
  }

  @override
  String get finalFare => '最終車資';

  @override
  String get holdReleased => '預授權已釋放';

  @override
  String chargeAmount(String amount) {
    return '扣款 $amount';
  }

  @override
  String get ridePaid => '騎乘費用已付款';

  @override
  String get paymentPending => '騎乘已結束 · 待付款';

  @override
  String get holdReleasedDescription => '剩餘測試預授權已釋放。';

  @override
  String get paymentPendingDescription => '自行車已安全歸還。請於下方重試模擬扣款。';

  @override
  String get rideId => '騎乘 ID';

  @override
  String get duration => '時長';

  @override
  String get returnedAt => '歸還時間';

  @override
  String get retryPayment => '重試付款';

  @override
  String get retry => '重試';

  @override
  String get rentAnotherBike => '再租一輛';

  @override
  String get pleaseWait => '請稍候…';

  @override
  String get timeBasedPricing => '依時間計費';

  @override
  String pricingFormula(String unlockFee, String minuteRate) {
    return '$unlockFee +（計費分鐘數 × $minuteRate）';
  }

  @override
  String pricingExample(int minutes) {
    return '$minutes 分鐘範例';
  }

  @override
  String get pricingTimerDescription => '計時器於自行車解鎖後啟動，車柱確認歸還後停止。';

  @override
  String get choosePaymentMethod => '選擇付款方式';

  @override
  String get personalCard => '個人卡片';

  @override
  String get travelCard => '交通卡';

  @override
  String get addCardFuture => '新增卡片功能將於未來的使用者模組中提供。';

  @override
  String get paypalSandbox => '測試付款';

  @override
  String get paypalSandboxDescription => '本機模擬 · 不涉及真實金錢';

  @override
  String get paypalAccountSubtitle => 'PayPal 沙盒帳戶';

  @override
  String get paypalCheckoutTitle => 'PayPal 付款';

  @override
  String get paypalCheckoutSemantics => '安全的 PayPal 付款核准頁面';

  @override
  String get selected => '已選取';

  @override
  String get selectable => '可選取';

  @override
  String get cityMapSemantics => '城市地圖，顯示目前自行車位置與還車站點';

  @override
  String get errorInvalidQr => '這個 QR 碼不是 BikeRent 的自行車。請掃描車身上的 QR 碼。';

  @override
  String errorBikeReserved(String bikeId) {
    return '自行車 $bikeId 已被預約。請選擇其他車輛並重新掃描。';
  }

  @override
  String errorBikeMaintenance(String bikeId) {
    return '自行車 $bikeId 正在維護中，無法租用。請選擇其他車輛並重新掃描。';
  }

  @override
  String errorBikeUnavailable(String bikeId) {
    return '自行車 $bikeId 目前無法使用，無法租用。請選擇其他車輛並重新掃描。';
  }

  @override
  String errorBikeLowBattery(String bikeId, int percent) {
    return '自行車 $bikeId 電量過低（$percent%），無法租用。最低需求為 10%。請選擇其他車輛並重新掃描。';
  }

  @override
  String get lowBatteryWarningTitle => '電量不足警告';

  @override
  String lowBatteryWarningMessage(String bikeId, int percent) {
    return '自行車 $bikeId 電量僅剩 $percent%。騎乘距離與馬達助力可能受限。要繼續嗎？';
  }

  @override
  String get continueButton => '繼續';

  @override
  String get bikeCannotBeRentedTitle => '無法租用此自行車';

  @override
  String errorHoldDeclined(String amount) {
    return '$amount 測試預授權被拒絕。準備好後可重試。';
  }

  @override
  String get errorPaymentConfiguration => '本機測試付款模擬器無法使用。';

  @override
  String get errorPaymentNetwork => '本機測試付款失敗。準備好後可重試。';

  @override
  String get errorPaymentCancelled => '測試付款核准已取消。準備好後可重試。';

  @override
  String get errorPaymentAuthorizationFailed => '測試付款無法完成預授權。準備好後可重試。';

  @override
  String get errorPaymentCaptureFailed => '測試付款無法扣取騎乘費用。付款仍處於待處理狀態，請於下方重試。';

  @override
  String get errorLockFailed => '車鎖沒有回應。請靠近車輛後重試。';

  @override
  String get errorGpsLost => 'GPS 訊號遺失。請移至開闊區域並檢查位置權限。';

  @override
  String errorStationFull(String station) {
    return '$station 沒有空閒車柱。請選擇其他站點。';
  }

  @override
  String get errorChooseStation => '請先選擇還車站點。';

  @override
  String get errorOutsideReturnZone => '歸還前請移動至所選站點 250 公尺範圍內。';

  @override
  String get errorStationQrMismatch => '該 QR 碼與所選站點不符。請掃描站點的 QR 碼海報或輸入站點代碼。';

  @override
  String get errorMaxExtensionsReached => '延長次數已用完。請歸還自行車以結束本次租借。';

  @override
  String get errorLocationPermissionDenied => '需要位置權限才能驗證歸還。請開啟後重試。';

  @override
  String get errorAccountSuspended => '帳號已停用：您有一輛自行車未歸還。請聯絡客服以恢復。';

  @override
  String get errorDockNotDetected => '未偵測到車柱。請將自行車用力推入車柱後重試。';

  @override
  String get errorAuthenticationFailed => '示範使用者登入失敗。請檢查 Supabase 後重試。';

  @override
  String get errorBackendConnection => '租車服務無法使用。請檢查連線後重試。';

  @override
  String get errorActiveRentalExists => '此使用者尚有未完成的租借。請先繼續或完成。';

  @override
  String errorStationMaintenance(String station) {
    return '站點 $station 正在維護中，無法在此租車或還車。';
  }

  @override
  String errorStationTerminated(String station) {
    return '站點 $station 已終止，無法在此租車或還車。';
  }

  @override
  String get errorStationMaintenanceGeneral => '該站點正在維護中，無法在此租車或還車。';

  @override
  String get errorStationTerminatedGeneral => '該站點已終止，無法在此租車或還車。';

  @override
  String get stationUnderMaintenance => '維護中';

  @override
  String get stationCannotReturnMaintenance => '該站點正在維護中，無法在此歸還自行車。';

  @override
  String get errorInvalidRentalTransition => '伺服器上的租借狀態已變更。請重試以恢復。';

  @override
  String get rideWarningDepositExceededTitle => '超過押金時限';

  @override
  String get rideWarningDepositExceededBody => '您借用自行車的時間已超過押金時限，將產生額外租借費用。';

  @override
  String get rideWarningLegalActionTitle => '法律行動警告';

  @override
  String get rideWarningLegalActionBody =>
      '租借時長已超過押金時限的 2 倍。若未歸還自行車，將立即採取法律行動。';

  @override
  String get rideWarningSuspiciousActivityTitle => '偵測到可疑活動';

  @override
  String get rideWarningSuspiciousActivityBody => '偵測到可疑活動：您距離取車站點異常遙遠。';

  @override
  String get rideWarningSuspiciousLegalTitle => '可疑活動與法律行動';

  @override
  String get rideWarningSuspiciousLegalBody =>
      '偵測到遠離站點的可疑活動，且已超過押金時限。若未歸還自行車，將立即採取法律行動。';

  @override
  String get addBike => '新增車輛';

  @override
  String get editBike => '編輯車輛';

  @override
  String get bikeDetail => '車輛詳細資訊';

  @override
  String get bikeReport => '車輛回報';

  @override
  String get transferBike => '轉移車輛';

  @override
  String get serviceBike => '檢修車輛';

  @override
  String get reportDetail => '回報詳細資訊';

  @override
  String get pendingReports => '待處理回報';

  @override
  String get newReport => '新回報';

  @override
  String get pendingReportDetails => '待處理回報詳細資訊';

  @override
  String get paymentMethods => '付款方式';

  @override
  String get conditionReports => '車況回報';

  @override
  String get reviewAndResolveBikeIssues => '審核並處理車輛問題。';

  @override
  String get trackSubmittedBikeReports => '追蹤您送出的車輛回報。';

  @override
  String get searchReportOrBikeId => '搜尋回報或車輛 ID';

  @override
  String get pending => '待處理';

  @override
  String get approved => '已核准';

  @override
  String get rejected => '已拒絕';

  @override
  String get cancelled => '已取消';

  @override
  String get reports => '回報';

  @override
  String get newestFirst => '最新優先';

  @override
  String get cancelReport => '取消回報';

  @override
  String get cancelReportQuestion => '取消回報？';

  @override
  String get keepReport => '保留回報';

  @override
  String cancelReportConfirmation(String reportId) {
    return '取消 $reportId？此回報將不再由管理員審核。';
  }

  @override
  String reportCancelled(String reportId) {
    return '已取消 $reportId。';
  }

  @override
  String failedToCancelReport(String error) {
    return '取消回報失敗：$error';
  }

  @override
  String get onlyPendingReportsCanBeCancelled => '僅待處理的回報可以取消。';

  @override
  String allReports(int count) {
    return '全部 $count';
  }

  @override
  String pendingReportsCount(int count) {
    return '待處理 $count';
  }

  @override
  String approvedReportsCount(int count) {
    return '已核准 $count';
  }

  @override
  String rejectedReportsCount(int count) {
    return '已拒絕 $count';
  }

  @override
  String cancelledReportsCount(int count) {
    return '已取消 $count';
  }

  @override
  String get noMatchingReports => '沒有符合的回報';

  @override
  String get noReportsYet => '尚無回報';

  @override
  String get tryDifferentSearchTerm => '請嘗試其他搜尋關鍵字。';

  @override
  String get bikeConditionReportsAppearHere => '車況回報會顯示在這裡。';

  @override
  String get reported => '已回報';

  @override
  String get unableToLoadReports => '無法載入回報';

  @override
  String get brakeSystem => '煞車系統';

  @override
  String get tyres => '輪胎';

  @override
  String get chainAndGears => '鏈條與變速';

  @override
  String get seatAndFrame => '座墊與車架';

  @override
  String get bellAndLights => '車鈴與車燈';

  @override
  String get qrLock => 'QR 碼 / 車鎖';

  @override
  String get other => '其他';

  @override
  String get unableToLoadReport => '無法載入回報';

  @override
  String get reportNotFound => '找不到回報';

  @override
  String get reportDetails => '回報詳細資訊';

  @override
  String get noStationAssigned => '未指派站點';

  @override
  String get reportInformation => '回報資訊';

  @override
  String get problem => '問題';

  @override
  String get reportIdLabel => '回報 ID';

  @override
  String get photo => '照片';

  @override
  String get photoUnavailable => '照片無法使用';

  @override
  String get photoCouldNotBeLoaded => '回報照片無法載入。';

  @override
  String get unableToDisplayPhoto => '無法顯示照片';

  @override
  String get attachedPhotoCouldNotBeDisplayed => '附加的照片無法顯示。';

  @override
  String get noPhotoAttached => '未附加照片';

  @override
  String get reportWithoutPhoto => '此回報送出時未附照片。';

  @override
  String get issueDescription => '問題描述';

  @override
  String get pendingReview => '待審核';

  @override
  String get pendingReviewDescription => '此回報尚未審核。';

  @override
  String get reportApproved => '回報已核准';

  @override
  String get reportRejected => '回報已拒絕';

  @override
  String get reviewed => '已審核';

  @override
  String get reviewNote => '審核備註';

  @override
  String get noReviewNoteProvided => '未提供審核備註。';

  @override
  String get reportCancelledStatus => '回報已取消';

  @override
  String get reportCancelledDescription => '您在審核前取消了此回報。';

  @override
  String get addNewBike => '新增車輛';

  @override
  String get step1BasicInformation => '步驟 1（共 3 步）• 基本資訊';

  @override
  String get step2QrCode => '步驟 2（共 3 步）• QR 碼';

  @override
  String get step3ReviewInformation => '步驟 3（共 3 步）• 確認資訊';

  @override
  String get bikeCode => '車輛代碼';

  @override
  String get enterBikeCode => '輸入車輛代碼';

  @override
  String get bikeCodeTooShort => '車輛代碼過短';

  @override
  String get initialStation => '初始站點';

  @override
  String get pleaseSelectStation => '請選擇站點';

  @override
  String get selectStation => '選擇站點';

  @override
  String get unableToLoadStations => '無法載入站點';

  @override
  String get noStationsAvailable => '沒有可用的站點。';

  @override
  String get noStationSelected => '未選取站點';

  @override
  String get batteryPercentage => '電量百分比';

  @override
  String get enterBatteryPercentage => '輸入電量百分比';

  @override
  String get invalidBatteryPercentage => '電量百分比無效';

  @override
  String get enterValidNumber => '請輸入有效數字';

  @override
  String get batteryRangeError => '電量必須介於 0 到 100 之間';

  @override
  String get battery => '電量';

  @override
  String get initialStatus => '初始狀態';

  @override
  String get status => '狀態';

  @override
  String get available => '可用';

  @override
  String get maintenance => '維護中';

  @override
  String get retired => '已退役';

  @override
  String get qrGeneratedAutomatically => '系統會自動產生唯一的 QR 碼權杖。';

  @override
  String get qrScanningDescription => 'QR 碼之後可包含此權杖，供掃描車輛時使用。';

  @override
  String get bikeQrCode => '車輛 QR 碼';

  @override
  String get qrTokenIdentifiesBike => '掃描時將使用以下權杖識別此車輛。';

  @override
  String get qrToken => 'QR 權杖';

  @override
  String get qrTokenNotGenerated => 'QR 碼權杖尚未產生';

  @override
  String get notGenerated => '未產生';

  @override
  String get qrPlaceholderDescription => '目前的 QR 碼圖片僅為預留位置。之後可依此權杖產生實際的 QR 碼。';

  @override
  String get generatedQrCode => '已產生的 QR 碼';

  @override
  String get next => '下一步';

  @override
  String get bikeInformation => '車輛資訊';

  @override
  String get notSelected => '未選取';

  @override
  String get bikeAddedSuccessfully => '車輛新增成功';

  @override
  String failedToAddBike(String error) {
    return '新增車輛失敗：$error';
  }

  @override
  String get managePaymentMethodsSubtitle => '管理信用卡/金融卡與 PayPal';

  @override
  String get termsOfService => '服務條款';

  @override
  String get termsOfServiceSubtitle => '租借規則、安全政策與責任條款';

  @override
  String get privacyPolicy => '隱私權政策';

  @override
  String get privacyPolicySubtitle => '資料保護、GPS 定位與隱私權';

  @override
  String get logOut => '登出';

  @override
  String get onlineCheckout => '線上結帳';

  @override
  String get savedCards => '已儲存的卡片';

  @override
  String savedCardsCount(int count) {
    return '已儲存 $count 張';
  }

  @override
  String get noCardsSaved => '尚未儲存任何卡片';

  @override
  String get noCardsSavedDescription => '新增 Visa 或 Mastercard，即可快速便利地一鍵租車。';

  @override
  String get addCard => '新增卡片';

  @override
  String get removeCard => '移除卡片';

  @override
  String removeCardConfirmation(String brand, String lastFour) {
    return '確定要移除尾號為 $lastFour 的 $brand 卡片嗎？';
  }

  @override
  String get cancel => '取消';

  @override
  String get remove => '移除';

  @override
  String get cardRemovedSuccess => '卡片移除成功';

  @override
  String get failedToRemoveCard => '卡片移除失敗';

  @override
  String cardSetAsDefault(String brand) {
    return '$brand 已設為預設付款方式';
  }

  @override
  String get failedToUpdateDefaultCard => '更新預設卡片失敗';

  @override
  String get editCard => '編輯卡片';

  @override
  String get cardUpdatedSuccess => '卡片更新成功';

  @override
  String get failedToUpdateCard => '卡片更新失敗';

  @override
  String get cardAddedSuccess => '卡片新增成功';

  @override
  String get failedToAddCard => '卡片新增失敗';

  @override
  String get cardNumber => '卡號';

  @override
  String get cardNumberHint => '4xxx xxxx xxxx xxxx';

  @override
  String get cardholderName => '持卡人姓名';

  @override
  String get cardholderNameHint => '例如：王小明';

  @override
  String get expiryDate => '有效期限';

  @override
  String get expiryDateHint => 'MM/YY';

  @override
  String get cvvCvc => 'CVV / CVC';

  @override
  String get cvvHint => '•••';

  @override
  String get setAsDefaultPaymentMethod => '設為預設付款方式';

  @override
  String get automaticallyUseCard => '租車時自動使用此卡';

  @override
  String get updateCard => '更新卡片';

  @override
  String cardExpiry(String month, String year) {
    return '$month/$year 到期';
  }

  @override
  String get activeCard => '啟用中的卡片';

  @override
  String get defaultBadge => '預設';

  @override
  String get cardOptions => '卡片選項';

  @override
  String get setAsDefault => '設為預設';

  @override
  String get editCardMenu => '編輯卡片';

  @override
  String get removeCardMenu => '移除卡片';

  @override
  String get payPal => 'PayPal';

  @override
  String get payPalBuiltIn => '內建';

  @override
  String get payPalSubtitle => 'WebView 結帳 · 隨時可用';

  @override
  String get payPalInformation => 'PayPal 資訊';

  @override
  String get payPalIntegration => 'PayPal 整合';

  @override
  String get payPalAlwaysAvailable => '隨時可用的付款選項';

  @override
  String get payPalDescription =>
      'PayPal 結帳於自行車租借授權時，透過應用程式內安全的 WebView 依需處理。無需儲存信用卡或金融卡資料，因此無法編輯或移除。';

  @override
  String get gotIt => '我知道了';

  @override
  String get cardholderPreview => '持卡人';

  @override
  String get cardholderNamePreview => '持卡人姓名';

  @override
  String get expiresPreview => '有效期限';

  @override
  String get agree => '同意';

  @override
  String get agreementConfirmation => '同意確認';

  @override
  String agreementNotice(String buttonText, String title) {
    return '輕觸上方或下方的「$buttonText」，即表示您已閱讀並接受這些$title。';
  }

  @override
  String agreeAndContinue(String buttonText) {
    return '$buttonText並繼續';
  }

  @override
  String get contactSupport => '有問題？請聯絡 support@bikerent.app';

  @override
  String errorLoadingStations(String error) {
    return '載入站點失敗：$error';
  }

  @override
  String get stationA => '站點 A';

  @override
  String get stationB => '站點 B';

  @override
  String get selectOriginStation => '選擇起點站點';

  @override
  String get selectDestinationStation => '選擇終點站點';

  @override
  String get underMaintenance => '維護中';

  @override
  String get selectedStationTooFar => '所選站點距離過遠';

  @override
  String get etaLabel => '預計抵達：';

  @override
  String get estimatedArrivalTime => '預估抵達時間（ETA）';

  @override
  String durationInMinutes(int minutes) {
    return '$minutes 分鐘';
  }

  @override
  String totalDistanceKm(String distance) {
    return '總距離：$distance 公里';
  }

  @override
  String get selectStationsToCalculateRoutePrompt => '請選擇站點 A 與站點 B 以計算路線。';

  @override
  String failedToLoadBikes(String error) {
    return '載入車輛失敗：$error';
  }

  @override
  String get invalidBikeIdError => '無法開啟：車輛 ID 無效';

  @override
  String get stationBikes => '站點車輛';

  @override
  String get locationCoordinatesNotProvided => '未提供位置座標';

  @override
  String get searchBikesCodeOrId => '依代碼或 ID 搜尋車輛';

  @override
  String get noBikesInStationYet => '此站點尚無自行車';

  @override
  String get noBikesMatchSearch => '沒有符合搜尋條件的車輛。';

  @override
  String get unknownStatus => '未知';

  @override
  String bikeStatus(String status) {
    return '狀態：$status';
  }

  @override
  String failedToLoadStations(String error) {
    return '載入站點失敗：$error';
  }

  @override
  String get searchStationHint => '搜尋站點代碼、名稱或地址…';

  @override
  String get longPressMapToAddStation => '長按地圖以新增站點';

  @override
  String get noMatchingStationsFound => '找不到符合的站點。';

  @override
  String get unnamedStation => '未命名站點';

  @override
  String get noAddress => '無地址';

  @override
  String get stationNameEmptyError => '站點名稱不可為空。';

  @override
  String get stationAddressEmptyError => '站點地址不可為空。';

  @override
  String get validCapacityError => '請輸入有效的最大容量數字。';

  @override
  String maxCapacityExceededError(int capacity, int bikes) {
    return '最大容量（$capacity）不可少於目前停放的車輛數（$bikes）。';
  }

  @override
  String get stationUpdatedSuccess => '站點更新成功！';

  @override
  String get stationAddedSuccess => '站點新增成功！';

  @override
  String failedToSaveStation(String error) {
    return '儲存站點失敗：$error';
  }

  @override
  String get removeStation => '移除站點';

  @override
  String get confirmRemoveStationBody => '確定要移除此站點嗎？';

  @override
  String get stationRemovedSuccess => '站點移除成功！';

  @override
  String failedToRemoveStation(String error) {
    return '移除站點失敗：$error';
  }

  @override
  String get changePhoto => '變更照片';

  @override
  String get stationName => '站點名稱';

  @override
  String get enterStationNameHint => '輸入站點名稱…';

  @override
  String get stationCode => '站點代碼';

  @override
  String get readOnly => '唯讀';

  @override
  String get address => '地址';

  @override
  String get enterStationAddressHint => '輸入站點地址…';

  @override
  String get operatingStatus => '營運狀態';

  @override
  String get currentDockedBikes => '目前停放車輛數';

  @override
  String get maxBikesPerStation => '每站最大車輛數';

  @override
  String get addStation => '新增站點';

  @override
  String get updateStation => '更新站點';

  @override
  String get viewBikesAtStation => '檢視站點車輛';

  @override
  String get noAddressSet => '未設定地址';

  @override
  String get noBikesAtStation => '此站點目前沒有車輛。';

  @override
  String stationDeactivatedSuccess(String stationName) {
    return '$stationName 已成功停用';
  }

  @override
  String get searchStationToRemove => '搜尋要移除的站點…';

  @override
  String get searchStationNameOrAddress => '搜尋站點名稱或地址…';

  @override
  String get noStationsFound => '找不到站點。';

  @override
  String bikesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 輛自行車',
    );
    return '$_temp0';
  }

  @override
  String get currentlySelected => '目前已選取';

  @override
  String get targetStationToRemove => '要移除的目標站點';

  @override
  String get closestToYou => '離您最近';

  @override
  String get reset => '重設';

  @override
  String get allActiveStations => '所有營運中的站點';

  @override
  String get nearbyStations => '附近站點';

  @override
  String stationSummarySubtitle(String address, int count, String distance) {
    return '$address • $count 輛自行車$distance';
  }

  @override
  String confirmRemoveStationTitle(String stationName) {
    return '確定要移除\n$stationName 嗎？';
  }

  @override
  String get actionIrreversibleWarning => '此操作無法復原，確定要繼續嗎？';

  @override
  String get removeLocation => '移除位置';

  @override
  String get okButton => '確定';

  @override
  String get scanningLabel => '掃描中…';

  @override
  String get flashlightTooltip => '手電筒';

  @override
  String get invalidQrTitle => '無效的 QR 碼';

  @override
  String reservationExpiresIn(String time) {
    return '預約將於 $time 後到期';
  }

  @override
  String get rentalTimedOutTitle => '租借逾時';

  @override
  String rentalTimedOutBody(int minutes) {
    return '您的自行車預約已超過 $minutes 分鐘時限，車輛已被釋放。';
  }

  @override
  String get forceEndedTitle => '管理員已結束本次租借';

  @override
  String get rentalEndedTitle => '租借已結束';

  @override
  String get rentalEndedBody => '您的租借已結束。隨時可以開始新的騎乘。';

  @override
  String returnAtStation(String station) {
    return '於 $station 歸還';
  }

  @override
  String get originStation => '起始站點';

  @override
  String get tripStartedHere => '行程由此開始';

  @override
  String get currentLocation => '目前位置';

  @override
  String get yourGpsPosition => '您的 GPS 位置';

  @override
  String get stationDetailsTooltip => '站點詳細資訊';

  @override
  String get addPaymentMethod => '新增付款方式';

  @override
  String get lowBatteryFallbackBike => '這輛自行車';

  @override
  String get errorStationFullGeneral => '附近站點目前沒有空閒車柱，請稍後再試。';

  @override
  String get termsNoticePrefix => '繼續進行租借流程，即視為您已閱讀並接受本應用程式的';

  @override
  String get termsNoticeMiddle => '與';

  @override
  String get termsNoticeSuffix => '。';

  @override
  String get rideHistoryLoadFailed => '無法載入騎乘紀錄。';

  @override
  String get noCompletedRides => '尚未有任何已完成的騎乘。';

  @override
  String get weatherConnectionFailedTitle => '連線失敗';

  @override
  String get weatherConnectionFailedBody => '無法連線至天氣服務。請檢查網路連線後重試。';

  @override
  String get weatherTimeoutTitle => '連線逾時';

  @override
  String get weatherTimeoutBody => '天氣服務回應時間過長。請檢查連線後重試。';

  @override
  String get weatherRateLimitTitle => '已達請求上限';

  @override
  String get weatherRateLimitBody => '天氣服務暫時忙碌。請稍候片刻後重試。';

  @override
  String get weatherLocationTitle => '位置無法使用';

  @override
  String get weatherLocationBody => '需要位置權限才能顯示目前天氣。請開啟 GPS 並授予權限。';

  @override
  String get weatherOutsideMalaysiaTitle => '超出服務範圍';

  @override
  String get weatherOutsideMalaysiaBody => '天氣預報僅適用於馬來西亞境內的位置。';

  @override
  String get weatherServiceTitle => '服務無法使用';

  @override
  String get weatherServiceBody => '天氣服務暫時無法使用。請稍後再試。';

  @override
  String get weatherNotFoundTitle => '天氣無法使用';

  @override
  String get weatherNotFoundBody => '找不到此位置的天氣預報。';

  @override
  String get weatherGenericTitle => '天氣無法使用';

  @override
  String get weatherGenericBody => '目前無法載入騎乘條件。請再試一次。';

  @override
  String get aqiModerate => '普通';

  @override
  String get aqiUnhealthy => '不健康';

  @override
  String get aqiVeryUnhealthy => '非常不健康';

  @override
  String get aqiHazardous => '危害';

  @override
  String get rideConditionsRateLimitSemantics => '騎乘條件。已達請求上限。';

  @override
  String rideConditionsErrorSemantics(String title, String message) {
    return '騎乘條件。$title：$message。';
  }

  @override
  String get pmSessionExpired => '登入階段已過期，請重新登入。';

  @override
  String get pmCardInUse => '無法刪除卡片：該卡片已用於進行中或待處理的租借。';

  @override
  String get pmDuplicateCard => '此卡片已登記於您的帳戶。';

  @override
  String pmValidationError(String detail) {
    return '驗證錯誤：$detail';
  }

  @override
  String get pmUnknownError => '發生未預期的錯誤，請再試一次。';

  @override
  String get cvCardNumberRequired => '請輸入卡號';

  @override
  String get cvCardDigitsOnly => '請輸入有效的卡號數字';

  @override
  String get cvCardBrandUnsupported => '僅支援 Visa 和 Mastercard';

  @override
  String cvCardNumberLength(int entered) {
    return '卡號必須為 16 位（已輸入 $entered/16）';
  }

  @override
  String get cvCardNumberTooLong => '卡號不能超過 16 位';

  @override
  String get cvCardChecksumFailed => '卡號無效（檢查碼驗證失敗）';

  @override
  String get cvExpiryRequired => '請輸入有效期限';

  @override
  String get cvExpiryFormat => '有效期限請以 MM/YY 格式輸入';

  @override
  String get cvExpiryInvalidMonth => '月份無效（應為 01–12）';

  @override
  String get cvExpiryInvalidYear => '有效期限年份無效';

  @override
  String get cvCardExpired => '卡片已過期';

  @override
  String get cvExpiryTooFar => '有效期限年份過遠';

  @override
  String get cvCvvRequired => '請輸入 CVV 碼';

  @override
  String get cvCvvLength => 'CVV 碼必須為 3 位';

  @override
  String get cvNameRequired => '請輸入持卡人姓名';

  @override
  String get cvNameTooShort => '姓名至少需要 2 個字元';

  @override
  String get cvNameTooLong => '姓名不能超過 50 個字元';

  @override
  String get cvNameInvalidChars => '僅允許字母、空格、連字號和點號';

  @override
  String get cvNameNeedsTwoParts => '請輸入名字與姓氏';

  @override
  String get cvNameDuplicate => '持卡人姓名已被其他卡片使用';

  @override
  String get verificationRequiredTitle => '需要身分驗證';

  @override
  String get verificationRequiredBody => '租借車輛前，請先填寫身分證號並完成人臉辨識驗證。';
}
