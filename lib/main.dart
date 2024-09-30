import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const GameScreen());
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int player = 1;
  int computer = 2;
  bool isComputerTurn = false;
  List board = [0, 0, 0, 0, 0, 0, 0, 0, 0];
  Timer? _timer;
  int time = 60;
  String status = 'Your turn';
  startTime() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (time > 0) {
        setState(() {
          time--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  runComputer() async {
    await Future.delayed(Duration(milliseconds: 200), () {
      int? blocking;
      int? winning;
      int? normal;

      for (int i = 0; i < board.length; i++) {
        List demoBoard = List.from(board);
        if (demoBoard[i] > 0) {
          continue;
        }

        demoBoard[i] = computer;
        if (hasWon(computer, demoBoard)) {
          winning = i;
        }
        demoBoard[i] = player;

        if (hasWon(player, demoBoard)) {
          blocking = i;
          //log(i.toString());
        }
        normal = i;
      }

      int move = winning ?? blocking ?? normal ?? 0;

      makeMove(computer, move);

      setState(() {
        board[move] = computer;
      });
      if (hasWon(player, board)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('You Won'),
          ),
        );
      }
    });
  }

  void makeMove(int check, int index) {
    print('playing $index');
    setState(() {
      board[index] = check;
    });
  }

  bool hasWon(int player, List board) {
    //012
    //345
    //678
    //036
    //147
    //258
    //048
    //246

    return board[0] == player && board[1] == player && board[2] == player ||
        board[4] == player && board[5] == player ||
        board[6] == player && board[7] == player && board[8] == player ||
        board[0] == player && board[1] == player && board[2] == player ||
        board[3] == player && board[4] == player && board[5] == player ||
        board[6] == player && board[7] == player && board[8] == player ||
        board[0] == player && board[3] == player && board[6] == player ||
        board[1] == player && board[4] == player && board[7] == player ||
        board[2] == player && board[5] == player && board[8] == player ||
        board[0] == player && board[4] == player && board[8] == player ||
        board[2] == player && board[4] == player && board[6] == player;
  }

//Async
  //Future
  //Stream
  /* Future greetUser() async {
    Future.delayed(Duration(seconds: 2), () {
      print('Am Delay 2 seconds');
    });

    print('I will print in the second position');
  }

  Future oneTo100() async {
    for (int i = 0; i < 60; i++) {
      await Future.delayed(Duration(seconds: 1), () {
        print(i);
      });
    }
  }*/

  @override
  void initState() {
    startTime();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: Container(
          alignment: Alignment.center,
          child: Text(
            '$time',
            style: TextStyle(fontSize: 20),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                if (_timer != null && !_timer!.isActive) {
                  startTime();
                } else {
                  setState(() {
                    _timer?.cancel();
                  });
                }
              },
              icon: Icon(_timer != null && _timer!.isActive
                  ? Icons.pause
                  : Icons.play_arrow)),
          IconButton(
              onPressed: () {
                _timer?.cancel();
                setState(() {
                  board = List.filled(9, 0);
                  time = 60;
                });
                startTime();
              },
              icon: const Icon(Icons.lock_reset_rounded))
        ],
      ),
      body: Column(
        children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  children: [
                    for (int i = 0; i < 9; i++)
                      GestureDetector(
                        onTap: () async {
                          if (!isComputerTurn) {
                            setState(() {
                              board[i] = player;
                              isComputerTurn = true;
                              status = 'Computer Turn';
                            });
                            await runComputer();
                            setState(() {
                              isComputerTurn = false;
                              status = 'Your Turn';
                            });
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: board[i] == player
                                ? Colors.green
                                : board[i] == computer
                                    ? Colors.redAccent
                                    : Colors.amber.shade300,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            board[i] == player
                                ? 'X'
                                : board[i] == computer
                                    ? 'O'
                                    : '',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                  ])),
          Text(
            status,
            style: const TextStyle(
              fontSize: 22,
            ),
          )
        ],
      ),
    );
  }
}
