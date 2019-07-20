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
    /// Network error
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
    /// Email or password incorrect
    internal static let wrongCredentials = L10n.tr("Localizable", "APIERROR.WRONG_CREDENTIALS")
  }

  internal enum Common {
    /// OK
    internal static let ok = L10n.tr("Localizable", "COMMON.OK")

    internal enum Textfield {
      /// Required
      internal static let `required` = L10n.tr("Localizable", "COMMON.TEXTFIELD.REQUIRED")
    }
  }

  internal enum Jog {

    internal enum Cancel {
      /// Cancel
      internal static let button = L10n.tr("Localizable", "JOG.CANCEL.BUTTON")
    }

    internal enum Pause {
      /// Pause
      internal static let button = L10n.tr("Localizable", "JOG.PAUSE.BUTTON")
    }

    internal enum Resume {
      /// Resume
      internal static let button = L10n.tr("Localizable", "JOG.RESUME.BUTTON")
    }

    internal enum Save {
      /// Save
      internal static let button = L10n.tr("Localizable", "JOG.SAVE.BUTTON")
    }

    internal enum Speed {
      /// %@ Km/h
      internal static func label(_ p1: String) -> String {
        return L10n.tr("Localizable", "JOG.SPEED.LABEL", p1)
      }
    }

    internal enum Start {
      /// Start
      internal static let button = L10n.tr("Localizable", "JOG.START.BUTTON")
    }

    internal enum Stop {
      /// Stop
      internal static let button = L10n.tr("Localizable", "JOG.STOP.BUTTON")
    }
  }

  internal enum Login {
    /// My Jogs
    internal static let title = L10n.tr("Localizable", "LOGIN.TITLE")

    internal enum Baritem {
      /// Sign Up
      internal static let signup = L10n.tr("Localizable", "LOGIN.BARITEM.SIGNUP")
    }

    internal enum Email {
      /// Email
      internal static let textfield = L10n.tr("Localizable", "LOGIN.EMAIL.TEXTFIELD")
    }

    internal enum Login {
      /// Login
      internal static let button = L10n.tr("Localizable", "LOGIN.LOGIN.BUTTON")
    }

    internal enum Password {
      /// Password
      internal static let textfield = L10n.tr("Localizable", "LOGIN.PASSWORD.TEXTFIELD")
    }
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

  internal enum Signup {
    /// My Jogs
    internal static let title = L10n.tr("Localizable", "SIGNUP.TITLE")

    internal enum Baritem {
      /// Login
      internal static let login = L10n.tr("Localizable", "SIGNUP.BARITEM.LOGIN")
    }

    internal enum Email {
      /// Email address not valid
      internal static let notvalid = L10n.tr("Localizable", "SIGNUP.EMAIL.NOTVALID")
      /// Email
      internal static let textfield = L10n.tr("Localizable", "SIGNUP.EMAIL.TEXTFIELD")
    }

    internal enum Password {
      /// Passwords different
      internal static let different = L10n.tr("Localizable", "SIGNUP.PASSWORD.DIFFERENT")
      /// Password must be at least 8 characters
      internal static let notvalid = L10n.tr("Localizable", "SIGNUP.PASSWORD.NOTVALID")
      /// Password
      internal static let textfield = L10n.tr("Localizable", "SIGNUP.PASSWORD.TEXTFIELD")
    }

    internal enum PasswordConfirm {
      /// Password confirm
      internal static let textfield = L10n.tr("Localizable", "SIGNUP.PASSWORD_CONFIRM.TEXTFIELD")
    }

    internal enum Signup {
      /// Sign up
      internal static let button = L10n.tr("Localizable", "SIGNUP.SIGNUP.BUTTON")
    }
  }

  internal enum Tabbar {

    internal enum Item {
      /// Record
      internal static let _1 = L10n.tr("Localizable", "TABBAR.ITEM.1")
      /// History
      internal static let _2 = L10n.tr("Localizable", "TABBAR.ITEM.2")
      /// Settings
      internal static let _3 = L10n.tr("Localizable", "TABBAR.ITEM.3")
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
