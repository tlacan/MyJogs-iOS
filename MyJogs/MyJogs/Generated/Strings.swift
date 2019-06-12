// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// swiftlint:disable explicit_type_interface identifier_name line_length nesting type_body_length type_name
internal enum L10n {

  internal enum Apierror {
    /// Access denied
    internal static let accessDenied = L10n.tr("Localizable", "APIERROR.ACCESS_DENIED")
    /// An error happened. Retry in a moment
    internal static let common = L10n.tr("Localizable", "APIERROR.COMMON")
    /// Name or Password unknown (reconnect)
    internal static let loginError = L10n.tr("Localizable", "APIERROR.LOGIN_ERROR")
    /// Netnork error
    internal static let networkError = L10n.tr("Localizable", "APIERROR.NETWORK_ERROR")
    /// Lost network connection
    internal static let nonetworkError = L10n.tr("Localizable", "APIERROR.NONETWORK_ERROR")
    /// Not connected
    internal static let notConnected = L10n.tr("Localizable", "APIERROR.NOT_CONNECTED")
    /// Unexpected error
    internal static let unexpectedError = L10n.tr("Localizable", "APIERROR.UNEXPECTED_ERROR")
    /// Unexpected error
    internal static let unexpectedResponse = L10n.tr("Localizable", "APIERROR.UNEXPECTED_RESPONSE")
    /// Unknown error
    internal static let unhandledErrorCode = L10n.tr("Localizable", "APIERROR.UNHANDLED_ERROR_CODE")
    /// Unknown email
    internal static let unknwonEmail = L10n.tr("Localizable", "APIERROR.UNKNWON_EMAIL")
    /// Email unknown
    internal static let unknwonUser = L10n.tr("Localizable", "APIERROR.UNKNWON_USER")
    /// User already exists
    internal static let userExists = L10n.tr("Localizable", "APIERROR.USER_EXISTS")
    /// Wrong password
    internal static let wrongCredentials = L10n.tr("Localizable", "APIERROR.WRONG_CREDENTIALS")
  }

  internal enum Main {

    internal enum App {
      /// My Jogs
      internal static let title = L10n.tr("Localizable", "Main.App.Title")
    }
  }

  internal enum Onboarding {

    internal enum End {
      /// Let's Go
      internal static let button = L10n.tr("Localizable", "ONBOARDING.END.BUTTON")
    }

    internal enum Step {

      internal enum _1 {
        /// Welcome to My Jogs\nthe application \nwhich tracks your jogs.
        internal static let description = L10n.tr("Localizable", "ONBOARDING.STEP.1.DESCRIPTION")
        ///  My Jogs
        internal static let title = L10n.tr("Localizable", "ONBOARDING.STEP.1.TITLE")
      }

      internal enum _2 {
        /// When you are ready to Run, Press Record
        internal static let description = L10n.tr("Localizable", "ONBOARDING.STEP.2.DESCRIPTION")
      }

      internal enum _3 {
        /// Track your runs put challenges and see your improvements.
        internal static let description = L10n.tr("Localizable", "ONBOARDING.STEP.3.DESCRIPTION")
      }
    }
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length nesting type_body_length type_name

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
