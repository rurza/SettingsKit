#if canImport(AppKit)
import Foundation

struct Localization {
	private static let localizedStrings: [String: String] = [
        "ar": "الإعدادات",
        "ca": "Configuració",
        "cs": "Nastavení",
        "da": "Indstillinger",
        "de": "Einstellungen",
        "el": "Ρυθμίσεις",
        "en": "Settings",
        "en-AU": "Settings",
        "en-GB": "Settings",
        "es": "Ajustes",
        "es-419": "Ajustes",
        "fi": "Asetukset",
        "fr": "Réglages",
        "fr-CA": "Réglages",
        "he": "הגדרות",
        "hi": "समायोजन",
        "hr": "Postavke",
        "hu": "Beállítások",
        "id": "Pengaturan",
        "it": "Impostazioni",
        "ja": "設定",
        "ko": "설정",
        "ms": "Tetapan",
        "nl": "Instellingen",
        "no": "Innstillinger",
        "pl": "Ustawienia",
        "pt": "Ajustes",
        "pt-PT": "Definições",
        "ro": "Configurări",
        "ru": "Настройки",
        "sk": "Nastavenia",
        "sv": "Inställningar",
        "th": "ค่าติดตั้ง",
        "tr": "Ayarlar",
        "uk": "Параметри",
        "vi": "Cài đặt",
        "zh-CN": "设置",
        "zh-HK": "設定",
        "zh-TW": "設定"
	]

	/**
	Returns the localized version of the given string.

	- Parameter identifier: Identifier of the string to localize.

	- Note: If the system's locale can't be determined, the English localization of the string will be returned.
	*/
	static func localizedString() -> String {
		// Force-unwrapped since all of the involved code is under our control.
		let localizedDict = Localization.localizedStrings
		let defaultLocalizedString = localizedDict["en"]!

		// Iterate through all user-preferred languages until we find one that has a valid language code.
		let preferredLocale = Locale.preferredLanguages
			// TODO: Use `.firstNonNil()` here when available.
			.lazy
			.map { Locale(identifier: $0) }
            .first {
                if #available(macOS 13, *) {
                    return $0.language.languageCode?.identifier != nil
                } else {
                    return $0.languageCode != nil
                }
            }
			?? .current

        let languageCode: String?
        if #available(macOS 13, *) {
            languageCode = preferredLocale.language.languageCode?.identifier
        } else {
            languageCode = preferredLocale.languageCode
        }
		guard let languageCode else {
			return defaultLocalizedString
		}

        let regionCode: String?
        if #available(macOS 13, *) {
            regionCode = preferredLocale.language.region?.identifier
        } else {
            regionCode = preferredLocale.regionCode
        }

		// Chinese is the only language where different region codes result in different translations.
		if languageCode == "zh" {
            let regionCode = regionCode ?? ""
			if regionCode == "HK" || regionCode == "TW" {
				return localizedDict["\(languageCode)-\(regionCode)"]!
			} else {
				// Fall back to "regular" zh-CN if neither the HK or TW region codes are found.
				return localizedDict["\(languageCode)-CN"]!
			}
		} else {
			if let localizedString = localizedDict[languageCode] {
				return localizedString
			}
		}

		return defaultLocalizedString
	}
}
#endif
