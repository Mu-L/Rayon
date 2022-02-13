//
//  ServerStatusView.swift
//  Rayon
//
//  Created by Lakr Aream on 2022/2/12.
//

import MachineStatus
import SwiftUI

public enum ServerStatusViews {
    struct BaseStatusView: View {
        @EnvironmentObject var info: ServerStatus

        public init() {}

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    ServerStatusViews.SystemInfo()
                    Divider()
                    ServerStatusViews.ProcessorInfoSummaryView()
                    Divider()
                    ServerStatusViews.MemoryInfoView()
                    Divider()
                    if info.graphics != nil {
                        ServerStatusViews.GraphicsView()
                        Divider()
                    }
                }
                Group {
                    ServerStatusViews.FileSystemView()
                    Divider()
                    ServerStatusViews.NetworkView()
                    Divider()
                }
                Text("Generated by Rayon, updated in real-time.")
                    .font(.system(.footnote, design: .rounded))
            }
            .font(.system(.body, design: .monospaced))
        }
    }

    public static func createBaseStatusView(withContext info: ServerStatus) -> some View {
        BaseStatusView()
            .environmentObject(info)
    }

    public struct SystemInfo: View {
        @EnvironmentObject var info: ServerStatus

        public init() {}

        public var body: some View {
            VStack {
                HStack {
                    Image(systemName: "gyroscope")
                    Text("System".uppercased())
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                    Text(info.system.releaseName)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Hostname" + ":")
                        Spacer()
                        Text(info.system.hostname)
                    }
                    HStack {
                        Text("Uptime" + ":")
                        Spacer()
                        Text(obtainUptimeDescription())
                    }
                    HStack {
                        Text("Running Process" + ":")
                        Spacer()
                        Text("\(info.system.runningProcs)").font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    HStack {
                        Text("Total Process" + ":")
                        Spacer()
                        Text("\(info.system.totalProcs)").font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    HStack {
                        Text("Average Load 1 min" + ":")
                        Spacer()
                        Text(info.system.load1.string(fractionDigits: 4))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    HStack {
                        Text("Average Load 5 min" + ":")
                        Spacer()
                        Text(info.system.load5.string(fractionDigits: 4))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    HStack {
                        Text("Average Load 15 min" + ":")
                        Spacer()
                        Text(info.system.load15.string(fractionDigits: 4))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    }
                    Divider().opacity(0)
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
            }
        }

        func format(duration: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute, .second]
            formatter.unitsStyle = .full
            formatter.maximumUnitCount = 1
            return formatter.string(from: duration) ?? ""
        }

        func obtainUptimeDescription() -> String {
            format(duration: info.system.uptimeSec)
        }
    }

    static func memoryFmt(KBytes: Float) -> String {
        bytesFmt(bytes: Int(exactly: KBytes * 1000) ?? 0)
    }

    static func bytesFmt(bytes: Int) -> String {
        let fmt = ByteCountFormatter()
        return fmt.string(fromByteCount: Int64(exactly: bytes) ?? 0)
    }
}

extension Float {
    func string(fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Double {
    func string(fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
