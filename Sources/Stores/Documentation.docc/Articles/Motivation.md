# Motivation

Why was Stores created?

---

When working on an app that uses the [composable architecture](https://github.com/pointfreeco/swift-composable-architecture), I fell in love with how reducers use an environment type that holds any dependencies the feature needs, such as API clients, analytics clients, and more.

**Stores** tries to abstract the concept of a store and provide various implementations that can be injected in such environment and swapped easily when running tests or based on a remote flag.

It all boils down to the two protocols ``SingleObjectStore`` and ``MultiObjectStore`` defined in the **Blueprints** layer, which provide the abstract concepts of stores that can store a single or multiple objects of a generic `Codable` type.

The two protocols are then implemented in the different modules as explained in the chart below:

![Modules chart](https://raw.githubusercontent.com/omaralbeik/Stores/main/Assets/stores-light.png)
