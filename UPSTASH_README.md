# Upstash Configuration

## Redis Instance Details

- **Host**: neutral-toad-19982.upstash.io
- **Port**: 6379 (default Redis port)
- **Protocol**: redis://
- **Password/Token**: AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA
- **Endpoint**: https://neutral-toad-19982.upstash.io

## REST API Configuration

The REST API provides HTTP access to your Upstash database:

- **Base URL**: https://neutral-toad-19982.upstash.io
- **Authentication Token**: AU4OAAIjcDFhMzAzZjcwYzM5ZWM0NWUyYWYwMWIyODY0MGRkNWE1YnAxMA
- **Headers Required**:
  - `Authorization: Bearer <token>`
  - `Content-Type: application/json`

⚠️ **IMPORTANT SECURITY NOTICE**: The token above is sensitive information. It should be:
- Stored in environment variables
- Never committed to version control
- Rotated regularly for security
- Shared only through secure channels

## Connection Information

To connect to this Redis instance, you'll need:
1. The host address: `neutral-toad-19982.upstash.io`
2. The authentication token (see above)
3. The endpoint URL: `https://neutral-toad-19982.upstash.io`

## Security Notes

- Keep your authentication credentials secure
- Never commit credentials to version control
- Use environment variables for sensitive information
- Consider using a secrets management service
- Regularly rotate credentials

## Usage in Flutter App

The app is configured to use this Redis instance through the `upstash_config.dart` file. Make sure to:
1. Set up proper environment variables
2. Configure the connection in your app's configuration
3. Handle connection errors appropriately
4. Store the token in a secure environment variable

## Support

For any issues with the Redis instance, contact Upstash support or refer to their [documentation](https://docs.upstash.com/). 