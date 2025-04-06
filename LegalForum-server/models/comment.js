const { Schema, model } = require("mongoose");
const { logger } = require('../utils/logger');

const commentSchema = new Schema(
    {
        detail: {
            type: String,
            min: [10, "Minimum 10 characters required"],
            max: [1000, "Maximum 1000 characters allowed"],
            required: true,
        },
        createdAt: {
            type: Number,
            default: () => Date.now(),
        },
        createdBy: {
            type: Schema.Types.ObjectId,
            ref: "user",
        },
    },
);

const Comment = model("comment", commentSchema);

module.exports = Comment;
