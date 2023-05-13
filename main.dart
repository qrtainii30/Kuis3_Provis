import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class UMKM {
  String name;
  String type;

  UMKM({required this.name, required this.type});
}

class UMKMCubit extends Cubit<List<UMKM>> {
  String url = "http://178.128.17.76:8000/daftar_umkm";

  UMKMCubit() : super([]) {
    fetchData();
  }

  void setFromJson(Map<String, dynamic> json) {
    List<UMKM> umkms = [];
    var data = json["data"];
    for (var val in data) {
      String name = val['nama'];
      String type = val['jenis'];
      umkms.add(UMKM(name: name, type: type));
    }
    emit(umkms);
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetilUMKM extends StatelessWidget {
  final int index;

  const DetilUMKM({required this.index});

  @override
  Widget build(BuildContext context) {
    final umkms = context.select((UMKMCubit cubit) => cubit.state);
    final selectedUMKM = umkms[index];

    return Scaffold(
      appBar: AppBar(
        title: Text('UMKM Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${selectedUMKM.name}'),
            Text('Detil: ${selectedUMKM.type}'),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UMKMCubit>(
          create: (context) => UMKMCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'My App',
        home: Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('My App')),
          ),
          body: Column(children: [
            const Text(
                '2105885, Qurrotu Ainii; 2102545, Zahra Fitria Maharani; Kami berjanji tidak akan berbuat curang dan atau membantu kelompok lain berbuat curang'),
            ElevatedButton(
              onPressed: () {
                context.read<UMKMCubit>().fetchData();
              },
              child: const Text('Reload Daftar UMKM'),
            ),
            Expanded(
              child: BlocBuilder<UMKMCubit, List<UMKM>>(
                builder: (context, umkms) {
                  return ListView.builder(
                    itemCount: umkms.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetilUMKM(index: index),
                              ),
                            );
                          },
                          leading: Image.network(
                            'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                          ),
                          trailing: const Icon(Icons.more_vert),
                          title: Text(umkms[index].name),
                          subtitle: Text(umkms[index].type),
                          tileColor: Colors.white70,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
