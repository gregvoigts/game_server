abstract class Observable {
  final List<Observer> _observers = [];

  Observable();

  void registerObserver(Observer observer) {
    _observers.add(observer);
  }

  void notify() {
    for (var observer in _observers) {
      observer.update();
    }
  }
}

abstract class Observer {
  Observer();

  void update() {}
}
