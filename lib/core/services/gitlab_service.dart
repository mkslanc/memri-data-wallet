import 'package:memri/core/apis/gitlab_api.dart';
import 'package:memri/core/services/api_service.dart';

class GitlabService extends ApiService<GitlabAPI> {
  GitlabService() : super(api: GitlabAPI());

  Future<String> getTextFileContentFromGitlab({
    required int gitProjectId,
    required String filename,
    String? branch,
  }) =>
      api
          .getTextFileContentFromGitlab(
              gitProjectId: gitProjectId, filename: filename, branch: branch)
          .catchError((error) => '');

  Future<String> downloadSingleArtifact({
    required int gitProjectId,
    required String filename,
    required String jobName,
    String? branch,
  }) =>
      api
          .downloadSingleArtifact(
              gitProjectId: gitProjectId,
              filename: filename,
              jobName: jobName,
              branch: branch)
          .catchError((error) => '');
}
