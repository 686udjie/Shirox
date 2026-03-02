import SwiftUI
#if os(iOS)
import UIKit

final class OrientationManager {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    static func requestRotation(to orientation: UIInterfaceOrientationMask) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation)) { _ in }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        return orientationLock
    }
}
#endif

@main
struct ShiroxApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    @StateObject private var moduleManager = ModuleManager.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }

                SearchView()
                    .tabItem { Label("Search", systemImage: "magnifyingglass") }

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            }
            .environmentObject(moduleManager)
            .task {
                await moduleManager.restoreActiveModule()
            }
        }
    }
}