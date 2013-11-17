class RoomViewController < UITableViewController
  def viewDidLoad
    super
    self.navigationItem.title = "The Motion Room"
    self.navigationItem.rightBarButtonItem = newBrowseButton
    self.navigationController.toolbarHidden = false
    self.tableView.dataSource = self
    self.tableView.delegate = self
    @messages = []
    presentAlert
  end

  def tableView(tableView, numberOfRowsInSection: section)
    @messages.count
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleValue1, reuseIdentifier: "cell")
    cell.textLabel.text = @messages[indexPath.row].text
    cell.detailTextLabel.text = @messages[indexPath.row].name
    cell
  end

  def receivedMessage(message)
    @messages << message
    queue = Dispatch::Queue.main.async { self.tableView.reloadData }
  end

  def sendMessage
    message = Message.new(@textfield.text, @sessionManager.name)
    @sessionManager.sendMessage message
    @textfield.text = nil
    receivedMessage(message)
  end

  def toolbarItems
    [newTextField, newSendButton]
  end

  def newSendButton
    UIBarButtonItem.alloc.initWithTitle("Send", style: UIBarButtonItemStylePlain, target: self, action: "sendMessage")
  end

  def newTextField
    @textfield = UITextField.alloc.initWithFrame CGRectMake(0, 40, 250, 32)
    @textfield.borderStyle = UITextBorderStyleRoundedRect
    buttonItem = UIBarButtonItem.alloc.initWithCustomView(@textfield)
    buttonItem
  end

  def presentAlert
    alert = UIAlertView.alloc.initWithTitle("Name", message: "Choose a display name", delegate: self,
                                            cancelButtonTitle: "Cancel", otherButtonTitles: "Ok", nil)
    alert.alertViewStyle = UIAlertViewStylePlainTextInput
    alert.show
  end

  def alertView(alert, clickedButtonAtIndex: index)
    if index == 0
      presentAlert
    else
      @sessionManager = SessionManager.alloc.initWithName(alert.textFieldAtIndex(0).text, andDelegate: self)
      NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
      NSNotificationCenter.defaultCenter.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    end
  end

  def keyboardWillShow(notification)
    moveKeyboard(true, notification: notification)
  end

  def keyboardWillHide(notification)
    moveKeyboard(false, notification: notification)
  end

  def moveKeyboard(up, notification: notification)
    toolbarFrame = self.navigationController.toolbar.frame
    keyboardFrame = Pointer.new(CGRect.type)
    notification.userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey).getValue(keyboardFrame)
    division = up ? -1 : 1
    rect = CGRectMake(toolbarFrame.origin.x, toolbarFrame.origin.y + (keyboardFrame[0].size.height * -1),
                      toolbarFrame.size.width, toolbarFrame.size.height)

    self.navigationController.toolbar.setFrame(rect)
  end

  def newBrowseButton
    UIBarButtonItem.alloc.initWithTitle("Browse", style: UIBarButtonItemStylePlain, target:self, action:"initiateBrowse")
  end

  def initiateBrowse
    browseController = MCBrowserViewController.alloc.initWithServiceType("Motion", session: @sessionManager.session)
    browseController.delegate = self
    self.presentViewController(browseController, animated: true, completion: nil)
  end

  def browserViewControllerDidFinish(browser)
    browser.dismissViewControllerAnimated(true, completion: nil)
  end

  def browserViewControllerWasCancelled(browser)
    browser.dismissViewControllerAnimated(true, completion: nil)
  end
end
