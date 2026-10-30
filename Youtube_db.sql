---1. Table Creation

CREATE TABLE Users (
    UserID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Username VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    RegistrationDate DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Channels (
    ChannelID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID INT NOT NULL REFERENCES Users(UserID),
    ChannelName VARCHAR(150) NOT NULL,
    Description TEXT,
    CreatedDate DATE DEFAULT CURRENT_DATE
);

CREATE TABLE Videos (
    VideoID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ChannelID INT NOT NULL REFERENCES Channels(ChannelID),
    Title VARCHAR(255) NOT NULL,
    Description TEXT,
    VideoURL TEXT,
    UploadDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    DurationSeconds INT,
    VisibilityStatus VARCHAR(20) DEFAULT 'public'
);

CREATE TABLE Comments (
    CommentID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    VideoID INT NOT NULL REFERENCES Videos(VideoID),
    UserID INT NOT NULL REFERENCES Users(UserID),
    CommentText TEXT NOT NULL,
    CommentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Likes (
    LikeID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    VideoID INT NOT NULL REFERENCES Videos(VideoID),
    UserID INT NOT NULL REFERENCES Users(UserID),
    LikeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (VideoID, UserID)
);

CREATE TABLE Subscriptions (
    SubscriptionID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID INT NOT NULL REFERENCES Users(UserID),
    ChannelID INT NOT NULL REFERENCES Channels(ChannelID),
    SubscriptionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (UserID, ChannelID)
);

CREATE TABLE Playlists (
    PlaylistID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID INT NOT NULL REFERENCES Users(UserID),
    PlaylistName VARCHAR(150) NOT NULL,
    Description TEXT,
    CreatedDate DATE DEFAULT CURRENT_DATE
);

CREATE TABLE PlaylistVideos (
    PlaylistVideoID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    PlaylistID INT NOT NULL REFERENCES Playlists(PlaylistID),
    VideoID INT NOT NULL REFERENCES Videos(VideoID),
    Position INT NOT NULL,
    UNIQUE (PlaylistID, VideoID)
);




---2. Data Insertion

-- 2.1. Users
INSERT INTO Users (Username, Email)
VALUES
('Rahul', 'rahul@example.com'),
('Priya', 'priya@example.com'),
('Aman', 'aman@example.com');

-- 2.2. Channels
INSERT INTO Channels (UserID, ChannelName, Description)
VALUES
(1, 'Rahul Tech', 'Technology and tutorials'),
(2, 'Priya Cooking', 'Cooking videos');

-- 2.3. Videos
INSERT INTO Videos
(ChannelID, Title, Description, VideoURL, DurationSeconds, VisibilityStatus)
VALUES
(1, 'SQL Basics', 'Introduction to SQL', 'https://example.com/video1', 600, 'public'),
(1, 'SQL Joins', 'Learn SQL joins', 'https://example.com/video2', 900, 'public'),
(2, 'Easy Pasta', 'Simple pasta recipe', 'https://example.com/video3', 480, 'public');

-- 2.4. Comments
INSERT INTO Comments (VideoID, UserID, CommentText)
VALUES
(1, 2, 'Very helpful video!'),
(2, 3, 'Please make more tutorials.'),
(3, 1, 'Looks delicious!');

-- 2.5. Likes
INSERT INTO Likes (VideoID, UserID)
VALUES
(1, 2),
(1, 3),
(3, 1);

-- 2.6. Subscriptions
INSERT INTO Subscriptions (UserID, ChannelID)
VALUES
(2, 1),
(3, 1),
(1, 2);

-- 2.7. Playlists
INSERT INTO Playlists (UserID, PlaylistName, Description)
VALUES
(2, 'Learn SQL', 'SQL learning videos'),
(1, 'My Favorites', 'Favorite videos');

-- 2.8. PlaylistVideos
INSERT INTO PlaylistVideos (PlaylistID, VideoID, Position)
VALUES
(1, 1, 1),
(1, 2, 2),
(2, 3, 1);




---3. Data Checking
SELECT 'Users' AS table_name, COUNT(*) AS total FROM Users
UNION ALL
SELECT 'Channels', COUNT(*) FROM Channels
UNION ALL
SELECT 'Videos', COUNT(*) FROM Videos
UNION ALL
SELECT 'Comments', COUNT(*) FROM Comments
UNION ALL
SELECT 'Likes', COUNT(*) FROM Likes
UNION ALL
SELECT 'Subscriptions', COUNT(*) FROM Subscriptions
UNION ALL
SELECT 'Playlists', COUNT(*) FROM Playlists
UNION ALL
SELECT 'PlaylistVideos', COUNT(*) FROM PlaylistVideos;


---4. See tables name available in public schema
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;



---5. PK & FK Validation
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
    AND tc.table_name = kcu.table_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type IN ('PRIMARY KEY', 'FOREIGN KEY')
ORDER BY tc.table_name, tc.constraint_type;




---6. Column & DataType Validation
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;



---7. check users table
SELECT *
FROM public."users"
LIMIT 10;



---7.1 Check Duplicate emails
SELECT
    "email",
    COUNT(*) AS total
FROM public."users"
GROUP BY "email"
HAVING COUNT(*) > 1;



---7.2 check Missing emails 
SELECT COUNT(*) AS missing_emails
FROM public."users"
WHERE "email" IS NULL;




---8. Connect three tables(users, channel, videos)
SELECT
    u.username,
    c.channelname,
    v.title AS video_title
FROM users u
JOIN channels c
    ON u.userid = c.userid
JOIN videos v
    ON c.channelid = v.channelid
ORDER BY u.userid, v.videoid;


---Data of related tables are ok with the help of FKs

-- 8.1 Users, Channels and Videos
SELECT
    u.UserID,
    u.Username,
    c.ChannelName,
    v.VideoID,
    v.Title
FROM Users u
LEFT JOIN Channels c ON u.UserID = c.UserID
LEFT JOIN Videos v ON c.ChannelID = v.ChannelID
ORDER BY u.UserID, v.VideoID;


-- 8.2 Videos and Comments
SELECT
    v.Title,
    u.Username,
    c.CommentText,
    c.CommentDate
FROM Comments c
JOIN Videos v ON c.VideoID = v.VideoID
JOIN Users u ON c.UserID = u.UserID;


-- 8.3 Videos and Likes
SELECT
    v.Title,
    COUNT(l.LikeID) AS total_likes
FROM Videos v
LEFT JOIN Likes l ON v.VideoID = l.VideoID
GROUP BY v.VideoID, v.Title
ORDER BY total_likes DESC;


-- 8.4 Users and Subscribed Channels
SELECT
    u.Username,
    c.ChannelName,
    s.SubscriptionDate
FROM Subscriptions s
JOIN Users u ON s.UserID = u.UserID
JOIN Channels c ON s.ChannelID = c.ChannelID;


-- 8.5 Playlists and Videos
SELECT
    p.PlaylistName,
    pv.Position,
    v.Title
FROM PlaylistVideos pv
JOIN Playlists p ON pv.PlaylistID = p.PlaylistID
JOIN Videos v ON pv.VideoID = v.VideoID
ORDER BY p.PlaylistID, pv.Position;




---9. Data quality validation (No duplicate values, missing fields or invalid values)

-- 9.1 Duplicate emails
SELECT Email, COUNT(*) AS total
FROM Users
GROUP BY Email
HAVING COUNT(*) > 1;


-- 9.2 Missing required usernames
SELECT *
FROM Users
WHERE Username IS NULL;


-- 9.3 Invalid video duration
SELECT *
FROM Videos
WHERE DurationSeconds < 0;


-- 9.4 Invalid visibility status
SELECT *
FROM Videos
WHERE VisibilityStatus NOT IN ('public', 'unlisted', 'private')
   OR VisibilityStatus IS NULL;


-- 9.5 Invalid playlist positions
SELECT *
FROM PlaylistVideos
WHERE Position <= 0;


-- 9.6 Duplicate likes by the same user on a video
SELECT VideoID, UserID, COUNT(*) AS total
FROM Likes
GROUP BY VideoID, UserID
HAVING COUNT(*) > 1;


-- 9.7 Duplicate subscriptions by the same user to a channel
SELECT UserID, ChannelID, COUNT(*) AS total
FROM Subscriptions
GROUP BY UserID, ChannelID
HAVING COUNT(*) > 1;



--- 10. simplified YouTube database se insights using SQL

-- 10.1 Total users
SELECT COUNT(*) AS total_users
FROM Users;


-- 10.2 Total channels
SELECT COUNT(*) AS total_channels
FROM Channels;


-- 10.3 Total videos uploaded
SELECT COUNT(*) AS total_videos
FROM Videos;


-- 10.4 Most liked videos
SELECT
    v.Title,
    COUNT(l.LikeID) AS total_likes
FROM Videos v
LEFT JOIN Likes l ON v.VideoID = l.VideoID
GROUP BY v.VideoID, v.Title
ORDER BY total_likes DESC;


-- 10.5 Most commented videos
SELECT
    v.Title,
    COUNT(c.CommentID) AS total_comments
FROM Videos v
LEFT JOIN Comments c ON v.VideoID = c.VideoID
GROUP BY v.VideoID, v.Title
ORDER BY total_comments DESC;


-- 10.6 Channels with the most subscribers
SELECT
    c.ChannelName,
    COUNT(s.SubscriptionID) AS total_subscribers
FROM Channels c
LEFT JOIN Subscriptions s ON c.ChannelID = s.ChannelID
GROUP BY c.ChannelID, c.ChannelName
ORDER BY total_subscribers DESC;


-- 10.7 Number of videos in each playlist
SELECT
    p.PlaylistName,
    COUNT(pv.VideoID) AS total_videos
FROM Playlists p
LEFT JOIN PlaylistVideos pv ON p.PlaylistID = pv.PlaylistID
GROUP BY p.PlaylistID, p.PlaylistName
ORDER BY total_videos DESC;




---11. Final schema validation summary

SELECT 'Users' AS table_name, COUNT(*) AS total_rows FROM Users
UNION ALL
SELECT 'Channels', COUNT(*) FROM Channels
UNION ALL
SELECT 'Videos', COUNT(*) FROM Videos
UNION ALL
SELECT 'Comments', COUNT(*) FROM Comments
UNION ALL
SELECT 'Likes', COUNT(*) FROM Likes
UNION ALL
SELECT 'Subscriptions', COUNT(*) FROM Subscriptions
UNION ALL
SELECT 'Playlists', COUNT(*) FROM Playlists
UNION ALL
SELECT 'PlaylistVideos', COUNT(*) FROM PlaylistVideos;


---13. Relationship testing
SELECT
    u.Username,
    c.ChannelName,
    v.Title AS VideoTitle
FROM Users u
LEFT JOIN Channels c
    ON u.UserID = c.UserID
LEFT JOIN Videos v
    ON c.ChannelID = v.ChannelID
ORDER BY u.UserID, v.VideoID;




