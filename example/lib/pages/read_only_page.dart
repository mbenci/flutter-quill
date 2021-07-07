import 'dart:convert';

import 'package:app/widgets/my_simple_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/widgets/simple_viewer.dart';

import '../universal_ui/universal_ui.dart';
import '../widgets/demo_scaffold.dart';

class ReadOnlyPage extends StatefulWidget {
  @override
  _ReadOnlyPageState createState() => _ReadOnlyPageState();
}

class _ReadOnlyPageState extends State<ReadOnlyPage> {
  final FocusNode _focusNode = FocusNode();
  GlobalKey Key = GlobalKey();

  QuillController? _controller;
  bool _edit = false;
  bool long = false;
  VoidCallback? callBack(bool isHashtag, String? id) {
    if (id != null) {
      if (isHashtag) {
        print('openHashtag $id');
      } else {
        print('openMention $id');
      }
    }
  }

  @override
  void initState() {
    _loadFromAssets();

    super.initState();
  }

  void getHeight() {
    print('getHeight 0');
    print('getHeight mounted --> $mounted');
    final state = Key.currentState;
    final cont = Key.currentContext;

    print('getHeight state --> $state');
    print('getHeight cont --> $cont');

    if (mounted && cont != null) {
      print('getHeight 1');
      try {
        final box = cont.findRenderObject() as RenderBox;
        print('box.size.height --> ${box.size.height}');
        print('box.size.height --> ${MediaQuery.of(context).size.height}');
        if (box.size.height > 200) {
          print('è LUNGO');
          setState(() {
            long = true;
          });
        } else if (long != false) {
          print('NON è LUNGO');
          setState(() {
            long = false;
          });
        }
      } catch (error) {
        // potrebbe dare errore quando pinnato, nella fase transitoria
        // non fare nulla (la descrizione non sarà più visibile comunque)
      }
    }
  }

  Future<void> _loadFromAssets() async {
    try {
      final result =
          await rootBundle.loadString('assets/sample_simple_data.json');
      //await rootBundle.loadString('assets/sample_empty_data.json');
      final doc = Document.fromJson(jsonDecode(result));
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    }
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      getHeight();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build 0');
    return Scaffold(
        body: SafeArea(
            child: Container(
      child: MyQuillSimpleViewer(
        globalKey: Key,
        controller: _controller!,
        truncateWidth: double.infinity,
        truncateHeight: long ? 200 : 1000,
        scrollBottomInset: 9.4,
        truncate: true,
        truncateScale: 1,
        padding: const EdgeInsets.all(10.0),
      ),
    )
            //TestWidget(_controller, key)
            ));

    /*return DemoScaffold(
      documentFilename: 'sample_simple_data.json',
      builder: _buildContent,
      showToolbar: _edit == true,
      floatingActionButton: FloatingActionButton.extended(
          label: Text(_edit == true ? 'Done' : 'Edit'),
          onPressed: _toggleEdit,
          icon: Icon(_edit == true ? Icons.check : Icons.edit)),
    );
  }

  Widget _buildContent(BuildContext context, QuillController? controller) {
    final quillEditor = QuillEditor(
        controller: controller!,
        scrollController: ScrollController(),
        scrollable: true,
        focusNode: _focusNode,
        autoFocus: true,
        readOnly: !_edit,
        expands: false,
        padding: EdgeInsets.zero,
        callBack: callBack,
        maxHeight: 190);
    /*if (kIsWeb) {
      quillEditor = QuillEditor(
          controller: controller,
          scrollController: ScrollController(),
          scrollable: true,
          focusNode: _focusNode,
          autoFocus: true,
          readOnly: !_edit,
          expands: false,
          padding: EdgeInsets.zero,
          embedBuilder: defaultEmbedBuilderWeb);
    }*/
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: quillEditor,
      ),
    );
    */
  }

  void _toggleEdit() {
    setState(() {
      _edit = !_edit;
    });
  }
}
