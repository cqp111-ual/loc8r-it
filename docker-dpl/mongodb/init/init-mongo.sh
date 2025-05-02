#!/bin/bash

echo "$(date) - Starting MongoDB initialization script..."

# Load environment variables with defaults if not set
MONGO_INITDB_ROOT_USERNAME="${DB_ROOT_USER:-admin}"
MONGO_INITDB_ROOT_PASSWORD="${DB_ROOT_PASS:-adminpass}"
APP_DB_NAME="${APP_DB_NAME:-appdb}"
APP_DB_USER="${APP_DB_USER:-appdbuser}"
APP_DB_PASS="${APP_DB_PASS:-appdbpass}"
HOST="${HOST:-localhost}"
PORT="${PORT:-27017}"

echo "$(date) - Connecting to MongoDB as admin..."

# Create application user (ignored if already exists)
mongosh --host "$HOST" --port "$PORT" \
  -u "$MONGO_INITDB_ROOT_USERNAME" \
  -p "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin <<EOF
use $APP_DB_NAME
try {
  db.createUser({
    user: "$APP_DB_USER",
    pwd: "$APP_DB_PASS",
    roles: [{ role: "readWrite", db: "$APP_DB_NAME" }]
  });
  print("User '$APP_DB_USER' created successfully.");
} catch (e) {
  print("User '$APP_DB_USER' already exists or could not be created: " + e);
}
quit()
EOF

echo "$(date) - User setup completed."

# Check if the 'locations' collection is empty
echo "$(date) - Checking if 'locations' collection is empty..."
DOC_COUNT=$(mongosh --quiet --host "$HOST" --port "$PORT" \
  -u "$MONGO_INITDB_ROOT_USERNAME" \
  -p "$MONGO_INITDB_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --eval "db.getSiblingDB('$APP_DB_NAME').locations.countDocuments()" 2>/dev/null)

if [[ "$DOC_COUNT" -eq 0 ]]; then
  echo "$(date) - Collection is empty. Inserting initial documents..."

  mongosh --host "$HOST" --port "$PORT" \
    -u "$MONGO_INITDB_ROOT_USERNAME" \
    -p "$MONGO_INITDB_ROOT_PASSWORD" \
    --authenticationDatabase admin <<EOF
use $APP_DB_NAME
db.locations.insertMany([
  {
    name: 'Starcups',
    address: '125 High Street, Reading, RG6 1PS',
    rating: 3,
    facilities: ['Hot drinks', 'Food', 'Premium wifi'],
    coords: [-0.9690884, 51.455041],
    openingTimes: [
      { days: 'Monday - Friday', opening: '7:00am', closing: '7:00pm', closed: false },
      { days: 'Saturday', opening: '8:00am', closing: '5:00pm', closed: false },
      { days: 'Sunday', closed: true }
    ]
  },
  {
    name: 'Taberna Entrevinos',
    address: 'Calle Francisco Gongora, 11',
    rating: 4,
    facilities: ['Hot drinks', 'Food', 'Premium wifi'],
    coords: [-2.4500605, 36.8388697],
    openingTimes: [
      { days: 'Monday - Friday', opening: '7:00am', closing: '7:00pm', closed: false },
      { days: 'Saturday', opening: '8:00am', closing: '5:00pm', closed: false },
      { days: 'Sunday', closed: true }
    ]
  },
  {
    name: 'Restaurante Valentin',
    address: 'Calle Tenor Iribarne, 19',
    rating: 4,
    facilities: ['Hot drinks', 'Food', 'Premium wifi'],
    coords: [-2.4649475, 36.8412037],
    openingTimes: [
      { days: 'Monday - Friday', opening: '7:00am', closing: '7:00pm', closed: false },
      { days: 'Saturday', opening: '8:00am', closing: '5:00pm', closed: false },
      { days: 'Sunday', closed: true }
    ]
  }
]);

db.locations.updateOne(
  { name: 'Starcups' },
  {
    $push: {
      reviews: {
        author: 'Simon Holmes',
        _id: ObjectId(),
        rating: 5,
        timestamp: new Date("Jul 16, 2013"),
        reviewText: "What a great place. I can't say enough good things about it."
      }
    }
  }
)

quit()
EOF

  echo "$(date) - Initial data inserted into 'locations' collection."
else
  echo "$(date) - Collection already contains $DOC_COUNT documents. Skipping data insertion."
fi

echo "$(date) - MongoDB initialization script completed."
