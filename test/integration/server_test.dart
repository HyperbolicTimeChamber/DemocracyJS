import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/vote_mode.dart';
import 'package:democracy_js/core/enums/results_visibility.dart';
import 'package:democracy_js/features/hosting/data/server/api_handler.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';
import 'package:democracy_js/features/poll/domain/entities/poll_option.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() {
  late HttpServer server;
  late Poll testPoll;
  final votedIps = <String>{};

  setUp(() async {
    final now = DateTime.now();
    testPoll = Poll(
      id: 'p1',
      question: 'Test?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.hosting,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );

    final handler = ApiHandler(
      getPoll: () => testPoll,
      onVote: (optionIds, ip) async {
        if (votedIps.contains(ip)) return false;
        votedIps.add(ip);
        return true;
      },
      getClientCount: () => 0,
    );

    server = await shelf_io.serve(handler.router.call, 'localhost', 0);
  });

  tearDown(() async {
    votedIps.clear();
    await server.close(force: true);
  });

  test('GET /api/poll returns poll data', () async {
    final client = HttpClient();
    final request =
        await client.get('localhost', server.port, '/api/poll');
    final response = await request.close();
    final body =
        jsonDecode(await response.transform(utf8.decoder).join());

    expect(response.statusCode, 200);
    expect(body['question'], 'Test?');
    client.close();
  });

  test('POST /api/vote accepts and rejects duplicate', () async {
    final client = HttpClient();

    // First vote
    var request =
        await client.post('localhost', server.port, '/api/vote');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'optionIds': ['o1']}));
    var response = await request.close();
    var body =
        jsonDecode(await response.transform(utf8.decoder).join());
    expect(body['success'], true);

    // Duplicate vote — same HttpClient reuses connection/IP
    request = await client.post('localhost', server.port, '/api/vote');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'optionIds': ['o2']}));
    response = await request.close();
    body = jsonDecode(await response.transform(utf8.decoder).join());
    expect(body['error'], 'already_voted');

    client.close();
  });
}
