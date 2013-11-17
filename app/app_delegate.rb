class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    controller = RoomViewController.alloc.init
    navigation_controller = UINavigationController.alloc.initWithRootViewController(controller)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = navigation_controller
    @window.makeKeyAndVisible

    true
  end
end
