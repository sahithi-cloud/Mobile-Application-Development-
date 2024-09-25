import 'util/stats.dart';
//main class Process
abstract class Process {
  String name;
  Process(this.name);

  List<Event> generateEvents();
}
//Singleton Process implementation
class SingletonProcess extends Process {
  int duration;
  int arrivalTime;

  SingletonProcess(String name, Map config)
      : duration = config['duration'],
        arrivalTime = config['arrival'],
        super(name);

  @override
  List<Event> generateEvents() {
    return [Event(name, arrivalTime, duration)]; 
  }
}
// Implementation of PeriodicProcess
class PeriodicProcess extends Process {
  int duration;
  int interarrivalTime;
  int firstArrival;
  int numRepetitions;

  PeriodicProcess(String name, Map config)
      : duration = config['duration'],
        interarrivalTime = config['interarrival-time'],
        firstArrival = config['first-arrival'],
        numRepetitions = config['num-repetitions'],
        super(name);

  @override
  List<Event> generateEvents() {
    List<Event> events = [];
    int arrivalTime = firstArrival;
int repetitions = 0; // Counter to track the number of repetitions

while (repetitions < numRepetitions) {
  events.add(Event(name, arrivalTime, duration));
  arrivalTime += interarrivalTime;
  repetitions++;
}

    return events;
  }
}
// Implementation Stochastic class 
class StochasticProcess extends Process {
  int firstArrival;
  int end;
  ExpDistribution durationDistribution;
  ExpDistribution interarrivalTimeDistribution;
//construction of stochastic process
  StochasticProcess(String name, Map config)
      : firstArrival = config['first-arrival'],
        end = config['end'],
        durationDistribution = ExpDistribution(mean: (config['mean-duration'] as num).toDouble()),
        interarrivalTimeDistribution = ExpDistribution(mean: (config['mean-interarrival-time'] as num).toDouble()),
        super(name); // referring the parent class name

  @override
  List<Event> generateEvents() {
    List<Event> events = [];
   

//iteration of events till end time 
for (int arrivalTime = firstArrival; arrivalTime < end;arrivalTime += interarrivalTimeDistribution.next().ceil()) {
  int duration = durationDistribution.next().ceil();
  events.add(Event(name, arrivalTime, duration));
}

    return events;
  }
}

// Creation of processes
class ProcessFactory {
  static final Map<String, Process Function(String, Map)> processCreators = {
    'singleton': (name, config) => SingletonProcess(name, config),
    'periodic': (name, config) => PeriodicProcess(name, config),
    'stochastic': (name, config) => StochasticProcess(name, config),
  };

  static Process createProcess(String name, Map config) {
    var processType = config['type'];
    var creator = processCreators[processType];
    
    if (creator != null) {
      return creator(name, config);
    } else {
      throw Exception('Unknown process type: ${processType}');
    }
  }
}


// Event class defined here
class Event {
  String processName;
  int arrivalTime;
  int duration;
  int? startTime;
  int waitTime = 0; //before event starts

  Event(this.processName, this.arrivalTime, this.duration);
}

