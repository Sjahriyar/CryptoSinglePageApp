## Choice of Design Pattern:

For this project, I have opted to implement the MVVM (Model-View-ViewModel) Clean Architecture without coordinators. The decision to use MVVM Clean Architecture stems from the fact that it provides a clear separation of concerns and promotes modularity, making the codebase easier to maintain and test. As it is a single view app, coordinators are not necessary in this context.

## SwiftUI and Combine:

To handle the asynchronous nature of data and provide a modern and streamlined user interface, I have chosen to utilize SwiftUI and Combine.

## URLSessionWebSocketTask instead of 3rd party libraries:

To establish a WebSocket connection and handle real-time data streaming, I have chosen to utilize URLSessionWebSocketTask, a native URLSession-based WebSocket implementation provided by Apple. Although there are third-party libraries available for WebSocket communication, I have opted for URLSessionWebSocketTask for this project. While it may offer fewer features compared to some third-party alternatives, it is a lightweight solution that integrates seamlessly with the existing URLSession infrastructure. This approach eliminates the need for additional dependencies, reduces the complexity of the project, and ensures compatibility with future iOS updates.

By utilizing SwiftUI, Combine, and URLSessionWebSocketTask, I aim to leverage the native capabilities of the iOS platform while keeping the project lightweight, maintainable, and future-proof. These choices allow for efficient development, streamlined code, and optimal performance in handling real-time data updates in the application.


## Testing:

Comin up
