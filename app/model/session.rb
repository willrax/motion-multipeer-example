class SessionManager
  attr_accessor :name, :delegate

  def initWithName(name, andDelegate: delgate)
    @name = name
    @delegate = delagate
    advertiser.start
    self
  end

  def sendMessage(message)
    data = message.text.dataUsingEncoding(NSUTF8StringEncoding)
    error = Pointer.new(:object)
    session.sendData(data, toPeers: session.connectedPeers, withMode: MCSessionSendDataReliable, error: error)
  end

  def session(session, didReceiveData: data, fromPeer: peer)
    text = NSString.alloc.initWithData(data, encoding: NSUTF8StringEncoding)
    user = peer.displayName
    message = Message.new(text, user)

    self.delegate.receivedMessage(message)
  end

  def session
    @session ||=
      begin
        peerId = MCPeerID.alloc.initWithDisplayName(name)
        session = MCSession.alloc.initWithPeer(peerId)
        session.delegate = self
        session
      end
  end

  def advertiser
    @advertiser ||= MCAdvertiserAssistant.alloc.initWithServiceType("Motion", discoveryInfo: nil, session: session)
  end

  def session(session, peer: peerId, didChangeState: state)
    case state
    when MCSessionStateConnected
      NSLog "Connected"
    when MCSessionStateNotConnected
      NSLog "Not Connected"
    when MCSessionStateConnecting
      NSLog "Connecting..."
    end
  end
end
