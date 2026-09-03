enum UserError { // got issue
  invalidEmail,
  emailRequired,
  passwordRequired,
  invalidCredentials,
  emailNotVerified,
  emailAlreadyRegistered,
  weakPassword,
  registrationFailed,
  loginFailed,
  logoutFailed,
  passwordResetFailed,
  notAuthenticated,
  connectionFailed,
  profileLoadFailed,
  displayNameRequired,
  profileUpdateFailed,
}

enum AppUserRole { rider, admin }

enum AccountStatus { active, suspended }

