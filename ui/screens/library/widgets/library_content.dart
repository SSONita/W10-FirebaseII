import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme.dart';
import '../../../utils/async_value.dart';
import '../view_model/library_item_data.dart';
import 'library_item_tile.dart';
import '../view_model/library_view_model.dart';

class LibraryContent extends StatelessWidget {
  const LibraryContent({super.key});

  @override
  Widget build(BuildContext context) {
    // 1- Read the globbal song repository
    LibraryViewModel mv = context.watch<LibraryViewModel>();

    AsyncValue<List<LibraryItemData>> asyncValue = mv.data;

    Widget content;
    switch (asyncValue.state) {
      case AsyncValueState.loading:
        content = Center(child: CircularProgressIndicator());
        break;
      case AsyncValueState.error:
        content = Center(
          child: Text(
            'error = ${asyncValue.error!}',
            style: TextStyle(color: Colors.red),
          ),
        );

      case AsyncValueState.success:
        List<LibraryItemData> data = asyncValue.data!;
        content = RefreshIndicator(
          onRefresh: () async {
            await mv.fetchSong(forceFetch: true);
          },
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => LibraryItemTile(
              data: data[index],
              isPlaying: mv.isSongPlaying(data[index].song),
              onTap: () {
                mv.start(data[index].song);
              },
              onLike: () {
                mv.likeSong(data[index].song);
              },
              // i said in doc that the LibraryScreen is the one that needed to be update
              // but actually the LibraryContent and LibraryItemTile is the one that needed to update :)
            ),
          )
        );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Row(
            children: [
              Text("Library", style: AppTextStyles.heading),
              IconButton(
                onPressed: () async {
                  await mv.fetchSong(forceFetch: true);
                },
                icon: const Icon(Icons.refresh),
              )
            ],
          ),
          SizedBox(height: 50),

          Expanded(child: content),
        ],
      ),
    );
  }
}
