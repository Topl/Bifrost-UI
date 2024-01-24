# Bifrost UI

A frontend monitoring tool for [Bifrost](https://github.com/Topl/Bifrost) blockchain nodes.

## Getting Started
1. Install [Flutter](https://docs.flutter.dev/get-started/install)
1. Run application
   ```sh
   flutter run
   ```

## Build with Docker
```
docker build -f Dockerfile --tag bifrost-ui:0.1.0 .
```

You can run the container on port `9999` with:

```
docker run -p 9999:80 bifrost-ui:0.1.0
```

Then access it by going to http://localhost:9999
