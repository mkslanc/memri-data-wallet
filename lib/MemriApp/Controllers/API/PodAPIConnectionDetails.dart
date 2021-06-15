//
//  PodAPIConnectionDetails.swift
//  MemriDatabase
//
//  Created by T Brennan on 17/12/20.
//

/// This type holds all the details required to connect to the pod and authenticate for a request
class PodAPIConnectionDetails {
  final String scheme;
  final String host;
  final int port;
  final String apiVersion;
  final String ownerKey;
  final String databaseKey;

  PodAPIConnectionDetails(
      {this.scheme = "http",
      this.host = "localhost",
      this.port = 3030,
      this.apiVersion = "v3",
      this.ownerKey = "ownerKeyHere",
      this.databaseKey = "databaseKeyHere"});
}
