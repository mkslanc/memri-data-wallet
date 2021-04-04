import 'package:flutter/material.dart';

class NavigationHolder {
  MemriUINavigationController controller;

  NavigationHolder(this.controller);
/*func makeUIViewController(context: Context) -> MemriUINavigationController { TODO
        return controller
    }
    
    func updateUIViewController(_ navController: MemriUINavigationController, context: Context) {

    }*/
}

class MemriUINavigationController extends Navigator {
  setViewControllers(List<Page> newPages) {
    //pages.clear();
    //pages.addAll(newPages);
  }

/*override func viewDidLoad() { TODO
        super.viewDidLoad()
        super.isNavigationBarHidden = true
    }
    
    override var isNavigationBarHidden: Bool {
        get { super.isNavigationBarHidden } set { super.isNavigationBarHidden = true }
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(true, animated: false)
    }*/
}
