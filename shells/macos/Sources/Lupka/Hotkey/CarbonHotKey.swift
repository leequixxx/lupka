import Carbon
import Foundation

struct HotKeyDefinition: Sendable {
    static let `default` = HotKeyDefinition(
        keyCode: UInt32(kVK_Space),
        modifiers: UInt32(controlKey) | UInt32(optionKey),
        displayName: "Control–Option–Space"
    )

    let keyCode: UInt32
    let modifiers: UInt32
    let displayName: String
}

enum CarbonHotKeyError: LocalizedError {
    case handlerInstallationFailed(OSStatus)
    case registrationFailed(OSStatus, displayName: String)

    var errorDescription: String? {
        switch self {
        case let .handlerInstallationFailed(status):
            "Lupka could not install the Carbon hotkey handler (OSStatus \(status))."
        case let .registrationFailed(status, displayName):
            "Lupka could not register \(displayName) (OSStatus \(status)). Another application may already use this shortcut. Close the conflicting application and restart Lupka."
        }
    }
}

@MainActor
final class CarbonHotKey {
    private let definition: HotKeyDefinition
    private let onPress: @MainActor () -> Void
    private let identifier = EventHotKeyID(signature: 0x6C70_6B61, id: 1)
    private var hotKeyReference: EventHotKeyRef?
    private var eventHandlerReference: EventHandlerRef?

    var isRegistered: Bool {
        hotKeyReference != nil
    }

    init(definition: HotKeyDefinition = .default, onPress: @escaping @MainActor () -> Void) {
        self.definition = definition
        self.onPress = onPress
    }

    func start() throws {
        guard hotKeyReference == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        let installationStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            carbonHotKeyHandler,
            1,
            &eventType,
            selfPointer,
            &eventHandlerReference
        )
        guard installationStatus == noErr else {
            throw CarbonHotKeyError.handlerInstallationFailed(installationStatus)
        }

        let registrationStatus = RegisterEventHotKey(
            definition.keyCode,
            definition.modifiers,
            identifier,
            GetApplicationEventTarget(),
            0,
            &hotKeyReference
        )
        guard registrationStatus == noErr else {
            if let eventHandlerReference {
                RemoveEventHandler(eventHandlerReference)
                self.eventHandlerReference = nil
            }
            throw CarbonHotKeyError.registrationFailed(
                registrationStatus,
                displayName: definition.displayName
            )
        }
    }

    func stop() {
        if let hotKeyReference {
            UnregisterEventHotKey(hotKeyReference)
            self.hotKeyReference = nil
        }
        if let eventHandlerReference {
            RemoveEventHandler(eventHandlerReference)
            self.eventHandlerReference = nil
        }
    }

    fileprivate func handleEvent(_ receivedIdentifier: EventHotKeyID) {
        guard receivedIdentifier.signature == identifier.signature,
            receivedIdentifier.id == identifier.id
        else {
            return
        }
        onPress()
    }
}

private let carbonHotKeyHandler: EventHandlerUPP = { _, event, userData in
    guard let event, let userData else {
        return OSStatus(eventNotHandledErr)
    }

    var identifier = EventHotKeyID()
    let parameterStatus = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &identifier
    )
    guard parameterStatus == noErr else {
        return parameterStatus
    }

    let hotKey = Unmanaged<CarbonHotKey>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async {
        hotKey.handleEvent(identifier)
    }
    return noErr
}
