# Plugins and SMPPaymentReceiptRequestVC

`SMPPaymentReceiptRequestVC` supports 🔌 plugins

Why plugins?
------------

- We want `SMPPaymentReceiptRequestVC` to generically interact with its children, without knowing what each child does or its specific needs.

- Plugins allow us to avoid using the `SMP_CONFIG_IS_APP`/`SMP_CONFIG_IS_SDK` macros, which prevent code from being moved to external packages. The SDK will one day share code via packages instead of via a SA build target.

- We can simplify imports by reducing the number of compile-time dependencies, which is important for the SDK. (There are still dependencies, but they are "linked" at runtime instead of compile-time.)

- We can make `SMPPaymentReceiptRequestVC` have a single responsibility by removing feature-specific logic from it.

How to add your own plugin
--------------------------

- Create a new class that conforms to `SMPPaymentReceiptRequestVCPluginProtocol`. 
  It will need a weak back-reference to `SMPPaymentReceiptRequestVC` (`paymentReceiptRequestVC`). This will be assigned automatically after your plugin is instantiated.

- Your plugin should have one initalizer that takes no arguments.

- If you need the view controller to call more methods/properties on your plugin, add them to `SMPPaymentReceiptRequestVCPluginProtocol` as needed. 
  Revise other plugins that conform to the protocol, for example by adding no-op versions of the new method(s) you added.

- If you need to manipulate the view controller, for example by changing its visual state, expose the methods/properties you need to access by adding them to `SMPPaymentReceiptRequestVCProtocol`.

- Make a call as early as possible to `SMPPaymentReceiptRequestVC` `registerPlugin:` in order to register your plugin's class.

Things to keep in mind
----------------------

- One drawback of plugins is the risk of *not knowing when a plugin was inadvertently not registered.*
  To mitigate this risk, add a test that calls `isPluginRegistered:` to verify that your registration call did happen.

- Because plugins can execute in any order, your plugin must not be dependent on the actions of other plugins.

- If the view controller needs to ask questions like "should this button be visible", consider using a "one or more plugins said YES" approach.

Further reading
---------------

Plugins are an application of the [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle) and also facilitate the [Open-Closed Principle](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle).
