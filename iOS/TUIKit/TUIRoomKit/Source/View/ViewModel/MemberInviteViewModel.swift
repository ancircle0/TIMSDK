//
//  MemberInviteViewModel.swift
//  TUIRoomKit
//
//  Created by 于西巍 on 2023/8/21.
//

import Foundation
import TUIRoomEngine

protocol MemberInviteResponder : NSObjectProtocol {
    func showCopyToast(copyType: CopyType)
}

class MemberInviteViewModel {
    private(set) var messageItems: [ListCellItemData] = []
    var store: RoomStore {
        EngineManager.createInstance().store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    //房间链接
    var roomLink: String? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        if bundleId == "com.tencent.tuiroom.apiexample" || bundleId == "com.tencent.fx.rtmpdemo" {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/" + "room?roomId=" + roomInfo.roomId
        } else if bundleId == "com.tencent.mrtc" {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "room?roomId=" + roomInfo.roomId
        } else {
            return nil
        }
    }
    weak var viewResponder: MemberInviteResponder?
    init() {
        createSourceData()
    }
    
    func createListCellItemData(titleText: String, messageText: String,
                                hasButton: Bool, copyType: CopyType) -> ListCellItemData {
        let item = ListCellItemData()
        item.titleText = titleText
        item.messageText = messageText
        item.hasRightButton = true
        item.normalIcon = "room_copy"
        item.normalText = .copyText
        item.resourceBundle = tuiRoomKitBundle()
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.copyAction(sender: button, text: item.messageText,copyType: copyType)
        }
        return item
    }
    
    func createSourceData() {
        let roomIdItem = createListCellItemData(titleText: .roomIdText, messageText: roomInfo.roomId, hasButton: true, copyType: .copyRoomIdType)
        messageItems.append(roomIdItem)
        
        if let roomLink = roomLink {
            let roomLinkItem = createListCellItemData(titleText: .roomLinkText, messageText: roomLink, hasButton: true, copyType: .copyRoomLinkType)
            messageItems.append(roomLinkItem)
        }
    }
    
    func dropDownAction(sender: UIView) {
        RoomRouter.shared.dismissPopupViewController(viewType: .inviteViewType, animated: true)
    }
    
    func copyAction(sender: UIButton, text: String, copyType: CopyType) {
        UIPasteboard.general.string = text
        viewResponder?.showCopyToast(copyType: copyType)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var roomIdText: String {
        localized("TUIRoom.room.num")
    }
    static var roomLinkText: String {
        localized("TUIRoom.room.link")
    }
    static var copyText: String {
        localized("TUIRoom.room.copy")
    }
}
