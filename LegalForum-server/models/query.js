const { Schema, model } = require("mongoose");
const { logger } = require('../utils/logger');

const querySchema = new Schema(
    {
        title: {
            type: String,
            min: [10, "Minimum 10 characters required"],
            max: [140, "Maximum 140 characters allowed"],
            required: true,
        },
        detail: {
            type: String,
            min: [10, "Minimum 10 characters required"],
            max: [1000, "Maximum 1000 characters allowed"],
            required: true,
        },
        status: {
            type: String,
            enum: ["opened", "assigned", "answered", "resolved"],
            default: "opened",
        },
        createdAt: {
            type: Number,
            default: () => Date.now(),
        },
        createdBy: {
            type: Schema.Types.ObjectId,
            ref: "user",
        },
        moderator: {
            type: Schema.Types.ObjectId,
            ref: "user",
        },
        panelist: {
            type: Schema.Types.ObjectId,
            ref: "user",
        },
        isPrivate: {
            type: Boolean,
            default: false,
        },
        tags: [
            {
                type: String,
            },
        ],
        category: {
            type: String,
            enum: [
                "general",
                "technical",
                "billing",
                "contracts",
                "intellectual property",
                "employment",
                "family law",
                "criminal law",
                "corporate law",
                "taxation",
                "real estate",
                "immigration",
                "litigation",
                "privacy",
                "compliance",
                "other",
            ],
            default: "general",
        },
        comments: [
            {
                type: Schema.Types.ObjectId,
                ref: "comment",
            },
        ],
    },
);

const Query = model("query", querySchema);

module.exports = Query;
