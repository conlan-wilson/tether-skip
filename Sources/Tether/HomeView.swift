//
//  HomeView.swift
//  tether-skip
//
//  Created by Conlan Wilson on 2025-11-01.
//

import SwiftUI
import TetherModel

// MARK: - Topographic Background

internal struct TopoBackground: View {
    @Environment(\.colorScheme) var cs
    @Environment(AppModel.self) var model
    
    internal let untethered: [Color] = [Color.gray]
    @State internal var tethered: [Color] = [Color.green]
    
    var body: some View {
        ZStack {
            if cs == .dark {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.05, green: 0.06, blue: 0.1),
                                                Color(red: 0.07, green: 0.09, blue: 0.12)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    gradient: Gradient(colors: [.white,
                                                .gray.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
            }
            if cs == .dark {
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: model.tetheredAnimation ? tethered : untethered),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        Image("topomap", bundle: .module)
                            .resizable()
                            .scaledToFill()
                    )
                    
                    .opacity(0.1)
                }
            }   else {
                VStack {
                    LinearGradient(
                        gradient: Gradient(colors: model.tetheredAnimation ? tethered : untethered),
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                      )
                      .mask(
                          Image("topomap", bundle: .module)
                              .resizable()
                              .scaledToFill()
                      )
                      
                      .opacity(0.1)
                }
            }
        }
        .onChange(of: model.myStatus) { old, newStatus in
            withAnimation {
                tethered = [newStatus.backgroundColor]
            }
            
        }
            
        
    }
}

struct HomeView: View {
    @Environment(AppModel.self) var model: AppModel
    @Environment(\.colorScheme) var cs
    
    @State internal var sizeOfOk: Double = 0.0
    @State internal var sizeOfMoving: Double = 0.0
    @State internal var sizeOfHelp: Double = 0.0
    @State internal var sizeOfMyStatusHeight: Double = 0.0
    @State internal var sizeOfMenuWidth: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.clear
            VStack {
                HStack {
                    Text("Home")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    Text("Grid")
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                }
                .padding(.top)
                Spacer()
                VStack(spacing: 0) {
                    HStack {
                        Text("User ID")
                            .foregroundStyle(.gray.opacity(1.0))
                            .fontWeight(.semibold)
                        Spacer()
                        Text(model.myShortId)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    HStack {
                        Text("Status")
                            .foregroundStyle(.gray.opacity(1.0))
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(model.tethered ? "" : "un")Tethered")
                            .fontWeight(.medium)
                            .foregroundStyle(model.tethered ? .blue : .red)
                        
                    }
                    .padding(.horizontal)
                    
                    if model.tetheredAnimation {
                        ZStack {
                            Color.clear
                                .frame(height: 10)
                            HStack(spacing: 0) {
                                if model.myStatus != .ok {
                                    Spacer()
                                        .frame(width:
                                                model.myStatus == .moving ? sizeOfMenuWidth-sizeOfHelp-sizeOfMoving-5 : sizeOfMenuWidth-sizeOfHelp
                                        )
                                }
                                Capsule()
                                    .fill(cs == .dark ?
                                          Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.5)
                                          :
                                            Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.1)
                                    )
                                    .frame(width: model.myStatus == .ok ? sizeOfOk : model.myStatus == .moving ? sizeOfMoving : sizeOfHelp, height: sizeOfMyStatusHeight)
                                if model.myStatus != .help {
                                    Spacer()
                                }
                            }
                            
                            .frame(width: sizeOfMenuWidth)
                            
                            
                            HStack(spacing: 5) {
                                menuMyStatus(.ok)
                                menuMyStatus(.moving)
                                menuMyStatus(.help)
                            }
                            .background(
                                GeometryReader { menuBackground in
                                    Color.clear
                                        .onAppear {
                                            sizeOfMenuWidth = menuBackground.size.width
                                        }
                                        .onChange(of: menuBackground.size) {
                                            sizeOfMenuWidth = menuBackground.size.width
                                        }
                                }
                            )
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            cs == .dark ?
                                .gray.opacity(0.3)
                            :
                                    .white.opacity(0.8)
                        )
                        .clipShape(Capsule())
                        
                        .padding(.top, 10)
                        .padding(.horizontal, 10)
                        #if os(Android)
                        .transition(.opacity)
                        #else
                        .transition(.blurReplace)
                        #endif
                    }
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                        .padding(.horizontal)
                    if model.tethered {
                        Button(action: {model.untether()}) {
                            HStack {
                                Spacer()
                                Text("unTether")
                                    .foregroundStyle(.white.opacity(1.0))
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 50)
                        .padding(.vertical, 25)
                        .background(
                            ZStack {
                                Color.black
                                    .opacity(0.7)
                                    .blur(radius: 10)
                                Color.black
                                    .opacity(0.5)
                                    
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.1), radius: 15, y: 5)
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else {
                        Button(action: {model.tether()}) {
                            HStack {
                                Spacer()
                                Text("Tether")
                                    .foregroundStyle(.white.opacity(1.0))
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 50)
                        .padding(.vertical, 25)
                        .background(
                            ZStack {
                                Color.black
                                    .opacity(0.7)
                                    .blur(radius: 10)
                                Color.black
                                    .opacity(0.5)
                                    
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.1), radius: 15, y: 5)
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                
                .background(
                    ZStack {
                        if cs == .dark {
                            ZStack {
                                Color(red: 0.95, green: 0.95, blue: 0.95)
                                    .opacity(0.3)
                                    .blur(radius: 15)
                                Color(red: 0.1, green: 0.1, blue: 0.1)
                                    .opacity(0.7)
                            }
                        } else {
                            ZStack {
                                Color(.white)
                                    .opacity(0.6)
                                    .blur(radius: 15)
                                Color(.gray)
                                    .opacity(0.1)
                            }
                        }
                        
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .foregroundStyle(.gray.opacity(0.3))
                )
                .padding()
            }
        }
        .background(
            TopoBackground()
                .ignoresSafeArea()
        )
        .onChange(of: model.myStatus) {
            print("Model myStatus: \(model.myStatus)")
        }
        
        
    }
    
    private func menuMyStatus(_ status: BeaconStatus) -> some View {
        
        Button(action: {withAnimation{model.myStatus = status}}) {
            HStack() {
                Image(systemName: status.image)
                    .foregroundStyle(status.color)
                    
                Text(status.label)
                    .foregroundStyle(model.myStatus == status ?
                                     (cs == .dark ?
                                        .white.opacity(0.7) : .black.opacity(0.7))
                                     :
                            .gray)
                    .fontWeight(model.myStatus == status ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(
                GeometryReader { menuMyStatusSize in
                    Color.clear
                        .onAppear {
                            switch status {
                            case .ok:
                                sizeOfOk = menuMyStatusSize.size.width
                            case .help:
                                sizeOfHelp = menuMyStatusSize.size.width
                            case .moving:
                                sizeOfMoving = menuMyStatusSize.size.width
                            }
                            sizeOfMyStatusHeight = menuMyStatusSize.size.height
                        }
                        .onChange(of: menuMyStatusSize.size) {
                            switch status {
                            case .ok:
                                sizeOfOk = menuMyStatusSize.size.width
                            case .help:
                                sizeOfHelp = menuMyStatusSize.size.width
                            case .moving:
                                sizeOfMoving = menuMyStatusSize.size.width
                            }
                            sizeOfMyStatusHeight = menuMyStatusSize.size.height
                        }
                    
                }
                
            )
        }
    }
    
}

#if !os(Android)
#Preview {
    ContentView()
        .environment(AppModel())
}
#endif

