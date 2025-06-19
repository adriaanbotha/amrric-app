# House Management API - CURL Commands for Upstash Redis

## Prerequisites
- Upstash Redis URL and Token
- Replace `YOUR_UPSTASH_URL` and `YOUR_UPSTASH_TOKEN` with your actual credentials

## Base Configuration
```bash
export UPSTASH_URL="YOUR_UPSTASH_URL"
export UPSTASH_TOKEN="YOUR_UPSTASH_TOKEN"
```

## House Management Endpoints

### 1. Get All Houses
```bash
curl -X GET \
  "$UPSTASH_URL/smembers/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 2. Get House by ID
```bash
curl -X GET \
  "$UPSTASH_URL/hgetall/house:house_darwin_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 3. Create New House
```bash
curl -X POST \
  "$UPSTASH_URL/hset/house:house_new_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "house_new_001",
    "locationId": "location_nt_001",
    "councilId": "council_nt_001",
    "houseNumber": "456",
    "streetName": "Cavenagh Street",
    "suburb": "Darwin",
    "postcode": "0800",
    "latitude": -12.4634,
    "longitude": 130.8456,
    "description": "New test house",
    "isActive": "true",
    "createdAt": "2025-01-20T10:00:00.000Z",
    "updatedAt": "2025-01-20T10:00:00.000Z"
  }'
```

### 4. Update House
```bash
curl -X POST \
  "$UPSTASH_URL/hset/house:house_darwin_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "house_darwin_001",
    "locationId": "location_nt_001",
    "councilId": "council_nt_001",
    "houseNumber": "123",
    "streetName": "Mitchell Street",
    "suburb": "Darwin",
    "postcode": "0800",
    "latitude": -12.4634,
    "longitude": 130.8456,
    "description": "Updated house description",
    "isActive": "true",
    "createdAt": "2025-01-20T10:00:00.000Z",
    "updatedAt": "2025-01-20T11:00:00.000Z"
  }'
```

### 5. Delete House
```bash
# First remove from index
curl -X POST \
  "$UPSTASH_URL/srem/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '["house_darwin_001"]'

# Then delete the house data
curl -X POST \
  "$UPSTASH_URL/del/house:house_darwin_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 6. Get Houses by Location
```bash
# Get all houses first, then filter by location
curl -X GET \
  "$UPSTASH_URL/smembers/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 7. Get Houses by Council
```bash
# Get all houses first, then filter by council
curl -X GET \
  "$UPSTASH_URL/smembers/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 8. Search Houses (Client-side filtering)
```bash
# Get all houses for client-side search
curl -X GET \
  "$UPSTASH_URL/smembers/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 9. Get House Statistics
```bash
# Get total count
curl -X GET \
  "$UPSTASH_URL/scard/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### 10. Bulk Create Houses
```bash
# Create multiple houses
curl -X POST \
  "$UPSTASH_URL/hset/house:house_bulk_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "house_bulk_001",
    "locationId": "location_nt_001",
    "councilId": "council_nt_001",
    "houseNumber": "789",
    "streetName": "Smith Street",
    "suburb": "Darwin",
    "postcode": "0800",
    "latitude": -12.4612,
    "longitude": 130.8423,
    "description": "Bulk created house 1",
    "isActive": "true",
    "createdAt": "2025-01-20T10:00:00.000Z",
    "updatedAt": "2025-01-20T10:00:00.000Z"
  }'

# Add to index
curl -X POST \
  "$UPSTASH_URL/sadd/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '["house_bulk_001"]'
```

## Test Data Validation

### Check if test houses exist
```bash
curl -X GET \
  "$UPSTASH_URL/smembers/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### Verify house data structure
```bash
curl -X GET \
  "$UPSTASH_URL/hgetall/house:house_darwin_001" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### Check house count
```bash
curl -X GET \
  "$UPSTASH_URL/scard/houses" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

## Error Handling Examples

### Test non-existent house
```bash
curl -X GET \
  "$UPSTASH_URL/hgetall/house:nonexistent" \
  -H "Authorization: Bearer $UPSTASH_TOKEN"
```

### Test invalid house data
```bash
curl -X POST \
  "$UPSTASH_URL/hset/house:invalid_house" \
  -H "Authorization: Bearer $UPSTASH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "invalid_house",
    "locationId": "",
    "councilId": "",
    "isActive": "true"
  }'
```

## Performance Testing

### Load test - Create multiple houses
```bash
for i in {1..10}; do
  curl -X POST \
    "$UPSTASH_URL/hset/house:load_test_$i" \
    -H "Authorization: Bearer $UPSTASH_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"id\": \"house:load_test_$i\",
      \"locationId\": \"location_nt_001\",
      \"councilId\": \"council_nt_001\",
      \"houseNumber\": \"$i\",
      \"streetName\": \"Test Street\",
      \"suburb\": \"Darwin\",
      \"postcode\": \"0800\",
      \"isActive\": \"true\",
      \"createdAt\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\",
      \"updatedAt\": \"$(date -u +%Y-%m-%dT%H:%M:%S.000Z)\"
    }"
  
  curl -X POST \
    "$UPSTASH_URL/sadd/houses" \
    -H "Authorization: Bearer $UPSTASH_TOKEN" \
    -H "Content-Type: application/json" \
    -d "[\"house:load_test_$i\"]"
done
```

## Cleanup Commands

### Remove all test houses
```bash
# Get all house IDs
HOUSE_IDS=$(curl -s -X GET "$UPSTASH_URL/smembers/houses" -H "Authorization: Bearer $UPSTASH_TOKEN" | jq -r '.[]')

# Delete each house
for house_id in $HOUSE_IDS; do
  curl -X POST "$UPSTASH_URL/del/house:$house_id" -H "Authorization: Bearer $UPSTASH_TOKEN"
done

# Clear the houses index
curl -X POST "$UPSTASH_URL/del/houses" -H "Authorization: Bearer $UPSTASH_TOKEN"
``` 