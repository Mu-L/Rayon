//
//  SessionTerminalView.swift
//  Rayon
//
//  Created by Lakr Aream on 2022/2/10.
//

import NSRemoteShell
import RayonModule
import SwiftUI
import XTerminalUI

struct SessionTerminalView: View {
    let token: UUID

    @StateObject
    var windowObserver: WindowObserver = .init()

    @EnvironmentObject var context: RDSession.Context

    @State var terminalSize = CGSize(width: 0, height: 0)
    @State var dataBuffer = ""
    @State var title: String = ""
    @State var shouldTerminate: Bool = false

    var body: some View {
        GeometryReader { r in
            TerminalManager.shared
                .loadTerminal(for: token)
                .coreUI
                .setupBufferChain {
                    dataBuffer.append($0)
                    let data = $0
                        .data(using: .utf8)?
                        .base64EncodedString()
                        ?? "base64 failed"
                    debugPrint("buffer \($0) data \(data)")
                    context.shell.explicitRequestStatusPickup()
                }
                .setupTitleChain {
                    title = $0
                    TerminalManager.shared
                        .loadTerminal(for: token)
                        .title = $0
                    setWindowTitle()
                    context.adjustTerminal(title: $0, for: token)
                }
                .frame(width: r.size.width, height: r.size.height)
                .onChange(of: r.size) { _ in updateTerminalSize() }
        }
        .padding(5)
        .onAppear {
            recoverViewStatus()
        }
        .onDisappear {
            context.adjustTerminal(title: title, for: token)
        }
        .background(
            HostingWindowFinder { [weak windowObserver] window in
                windowObserver?.window = window
                setWindowTitle()
            }
        )
        .onAppear {
            setWindowTitle()
        }
        .onDisappear {
            clearWindowTitle()
        }
    }

    func setWindowTitle() {
        windowObserver.window?.title = "Terminal"
        windowObserver.window?.subtitle = title.count > 0 ? title : "Untitled/Unrecognized Channel"
    }

    func clearWindowTitle() {
        windowObserver.window?.title = ""
        windowObserver.window?.subtitle = ""
    }

    func updateTerminalSize() {
        let coreUI = TerminalManager.shared
            .loadTerminal(for: token)
            .coreUI
        let origSize = terminalSize
        DispatchQueue.global().async {
            let newSize = coreUI.requestTerminalSize()
            mainActor {
                if newSize != origSize {
                    debugPrint("new terminal size: \(newSize)")
                    terminalSize = newSize
                    context.shell.explicitRequestStatusPickup()
                }
            }
        }
    }

    func acquireDataBuffer() -> String {
        if Thread.isMainThread {
            let buffer = dataBuffer
            dataBuffer = ""
            return buffer
        } else {
            let sem = DispatchSemaphore(value: 0)
            var buffer = ""
            DispatchQueue.main.async {
                defer { sem.signal() }
                buffer = acquireDataBuffer()
            }
            sem.wait()
            return buffer
        }
    }

    func recoverViewStatus() {
        let core = TerminalManager.shared
            .loadTerminal(for: token)
        title = core.title
        core.rebindChain {
            updateTerminalSize()
            return terminalSize
        } writeData: {
            acquireDataBuffer()
        } output: { output in
            mainActor {
                TerminalManager.shared
                    .loadTerminal(for: token)
                    .coreUI
                    .write(output)
            }
        } continuationHandler: {
            !shouldTerminate
        }
        core.startIfNeeded(with: context.shell)
    }
}
