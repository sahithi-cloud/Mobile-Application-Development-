import 'processes.dart';

class Simulator {
  final Map config;
  final bool verbose;
  List<Event> eventQueue = []; 
  List<Event> completedEvents = []; // stores completed events

  Simulator(this.config, {this.verbose =false});

  void run() {

  List<Process> processes = []; //list of process instances
  
  //creating instances and adding to the list
  config.forEach((processName, processConfig) {
    Process process = ProcessFactory.createProcess(processName, processConfig);
    processes.add(process);
  });

  // Generate events from processes
  processes.forEach((process) {
    eventQueue.addAll(process.generateEvents());
  });

  // Events sort according to arrival time
  eventQueue.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

  int currentTime = 0;
//implementing events till the queue is empty
  do {
    // getting event from the queue
    Event event = eventQueue.removeAt(0);
    if (event.arrivalTime > currentTime) {
      currentTime = event.arrivalTime;
    }

    // wait time
    event.startTime = currentTime;
    event.waitTime = currentTime - event.arrivalTime;
    completedEvents.add(event);

    if (verbose) {
      print('t=${event.startTime}: ${event.processName}, '
            'duration ${event.duration} started '
            '(arrived @ ${event.arrivalTime}, waited ${event.waitTime})');
    }

    currentTime += event.duration;
  } while (eventQueue.isNotEmpty);

  printReport(processes);
}

  void printReport(List<Process> processes) {
    
    print('\n# Per-process statistics\n');
    processes.forEach((process) {
      var events = completedEvents.where((event) => event.processName == process.name).toList();
      var totalWaitTime = events.fold(0, (sum, event) => sum + event.waitTime);
      var averageWaitTime = totalWaitTime / events.length;
      print('${process.name}:');
      print('  Events generated:  ${events.length}');
      print('  Total wait time:   $totalWaitTime');
      print('  Average wait time: ${averageWaitTime.toStringAsFixed(2)}');
    });

    print('\n# Summary statistics\n');
    var totalEvents = completedEvents.length;
    var totalWaitTime = completedEvents.fold(0, (sum, event) => sum + event.waitTime);
    var averageWaitTime = totalWaitTime / totalEvents;
    print('Total num events:  $totalEvents');
    print('Total wait time:   $totalWaitTime');
    print('Average wait time: ${averageWaitTime.toStringAsFixed(2)}');
  }
}