CREATE TRIGGER trg_AutoIncrement_MessageId
ON [message]
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @maxID INT;

    SELECT @maxID = COALESCE(MAX(id), 0) FROM [message] WHERE senderId = inserted.senderId AND receiverId = inserted.receiverId;

    INSERT INTO courseObjectives (id, senderId, receiverId, content, sentTime)
    SELECT @maxID + 1, senderId, receiverId, content, NOW()
    FROM inserted;
END