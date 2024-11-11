//
//  PlayerAreaView.swift
//  GG
//
//  Created by Vito Royeca on 11/2/24.
//

import SwiftUI

struct PlayerAreaView: View {
    let proxy: GeometryProxy
    let player: FPlayer
    let viewModel: GameViewModel
    
    @State private var isShowingSurrender = false

    var body: some View {
        let width = proxy.size.width / CGFloat(GameViewModel.columns)
        let height = width
        
        HStack {
            AvatarView(player: player,
                       width: width,
                       height: height)
            Text(player.isLoggedInUser ? "You" : player.username)
                .font(.headline)
                .foregroundStyle(.white)
            Spacer()
            if player.isLoggedInUser {
                createSurrenderButton()
            }
        }
    }
    
    @ViewBuilder
    private func createSurrenderButton() -> some View {
        Button {
            if viewModel.isGameOver {
                viewModel.quit()
                ViewManager.shared.changeView(to: .homeView)
            } else {
                isShowingSurrender = true
            }
        } label: {
            Image(systemName: viewModel.isGameOver ? "door.left.hand.open" : "flag.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.white)
        }
        .frame(width: 20, height: 20)
        .alert(isPresented:$isShowingSurrender) {
            let titleText = "Leave the battle?"

            return Alert(
                title: Text(titleText),
                message: Text("You will lower you ranking if you leave the battle."),
                primaryButton: .destructive(Text("Yes")) {
                    viewModel.quit()
                    ViewManager.shared.changeView(to: .homeView)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    GeometryReader { proxy in
        PlayerAreaView(proxy: proxy,
                       player: FPlayer.emptyPlayer,
                       viewModel: GameViewModel(gameType: .aiVsAI))
    }
}
