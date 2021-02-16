import Cocoa

public extension FourCharCode {
    var stringValue: String {
        return UTCreateStringForOSType(self).takeRetainedValue() as String
    }
    init(_ string: String) {
        self = UTGetOSTypeFromString(string as CFString)
    }
}

public protocol ResForgePlugin: class {
    /// The list of resource types that this plugin supports.
    static var editedTypes: [String] { get }
    
    var resource: Resource { get }
    init?(resource: Resource)
    
    func saveResource(_ sender: Any)
    func revertResource(_ sender: Any)
    
    /// You can return here the filename extension for your resource type. By default the host application substitutes the resource type if you do not implement this.
    static func filenameExtension(for resourceType: String) -> String?
    
    /// Implement this if the plugin needs to control the data that gets written to disk on export. By default the host application writes the raw resource data.
    /// The idea is that this export function is non-lossy, i.e. only override this if there is a format that is a 100% equivalent to your data.
    static func export(_ resource: Resource, to url: URL) -> Bool

    /// Return an NSImage representing the resource for use in grid view.
    static func image(for resource: Resource) -> NSImage?
    
    /// Return the preferred preview size for grid view.
    static func previewSize(for resourceType: String) -> Int?
    
    /// Return a placeholder name to show for a resource when it has no name.
    static func placeholderName(for resource: Resource) -> String?
}

public protocol ResForgeTemplatePlugin: ResForgePlugin {
    init?(resource: Resource, template: Resource)
}

/// If your bundle consists of multiple editors for different types, the principal class should implement this to provide a list of all the plugin classes.
public protocol ResForgePluginPackage {
    static var pluginClasses: [ResForgePlugin.Type] { get }
    static func placeholderName(for resource: Resource) -> String?
}

public protocol ResForgePluginManager: class {
    func open(resource: Resource, using editor: ResForgePlugin.Type?, template: String?)
    func allResources(ofType: String, currentDocumentOnly: Bool) -> [Resource]
    func findResource(ofType: String, id: Int, currentDocumentOnly: Bool) -> Resource?
    func findResource(ofType: String, name: String, currentDocumentOnly: Bool) -> Resource?
    func createResource(ofType: String, id: Int, name: String)
}

// Default implementations for optional functions
public extension ResForgePlugin {
    static func filenameExtension(for resourceType: String) -> String? { nil }
    static func export(_ resource: Resource, to url: URL) -> Bool { false }
    static func image(for resource: Resource) -> NSImage? { nil }
    static func previewSize(for resourceType: String) -> Int? { nil }
    static func placeholderName(for resource: Resource) -> String? { nil }
}
public extension ResForgePluginPackage {
    static func placeholderName(for resource: Resource) -> String? { nil }
}