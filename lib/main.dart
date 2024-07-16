import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

String jsonUrl = 'https://jsonplaceholder.typicode.com/posts';

final postFutureProvider = FutureProvider.autoDispose<String?>(
  (ref) async {
    ref.onDispose(() {
      print('onDispose');
    });
    final response = await http.get(Uri.parse('${jsonUrl}/1'));
    if (response.statusCode == 200) {
      return response.body;
    }
  },
);

final tmpProvider = StateProvider.family(
  (ref, int arg) => arg + 0,
);

final idStateProvider = StateProvider(
  (ref) => 1,
);

final postFutureProviderFamily = FutureProvider.family(
  (ref, int id) async {
    // final _id = ref.watch(idStateProvider);
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'));
    if (response.statusCode == 200) {
      return response.body;
    }
  },
);

void main() {
  final container = ProviderContainer();
  final tmpCounter1 = container.read(tmpProvider(1));
  final tmpCounter5 = container.read(tmpProvider(5));
  print(tmpCounter1.toString());
  print(tmpCounter5.toString());
  runApp(
    ProviderScope(
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SecondPage(),
                ),
              );
            },
            child: Text('다음 페이지'),
          ),
          // child: Consumer(
          //   builder: (BuildContext context, WidgetRef ref, Widget? child) {
          //     final id = ref.watch(idStateProvider);
          //     final post = ref.watch(postFutureProviderFamily(id));
          //     return post.when(
          //       data: (data) {
          //         return Text('${data}');
          //       },
          //       error: (error, trace) => Text('${error}'),
          //       loading: () => CircularProgressIndicator(),
          //     );
          //   },
          // ),
        ),
        floatingActionButton: Consumer(
          builder: (context, ref, child) {
            return FloatingActionButton(
              onPressed: () {
                ref
                    .read(idStateProvider.notifier)
                    .update((state) => state += 1);
              },
              tooltip: 'Increment',
              child: const Icon(
                Icons.add,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer(
          builder: (context, ref, child) {
            final post = ref.watch(postFutureProvider);
            return post.when(
              data: (data) {
                return Text('$data');
              },
              error: (e, t) {
                return Text('$e');
              },
              loading: () => CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
