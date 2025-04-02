enum LocationType {
  urban,
  rural,
  remote,
  indigenous,
}

String getLocationTypeName(LocationType locationType) {
  switch (locationType) {
    case LocationType.urban:
      return 'Urban';
    case LocationType.rural:
      return 'Rural';
    case LocationType.remote:
      return 'Remote';
    case LocationType.indigenous:
      return 'Indigenous';
  }
} 