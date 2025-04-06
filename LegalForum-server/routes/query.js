var express = require('express');
var router = express.Router();
const { Query, User, Comment } = require('../models');
const { logger } = require('../utils/logger');
const { auth } = require('../middleware');

const populateQuery = [
    { path: 'createdBy' },
    { path: 'moderator' },
    { path: 'panelist' },
    {
        path: 'comments',
        populate: { path: 'createdBy' }
    }
]

router.post('/query/create', auth, async (req, res) => {
    try {
        const { _id: userId } = req.session;
        req.body.createdBy = userId;
        const newQ = await Query.create(req.body);
        const query = await Query.findById
            (newQ._id)
            .select(["-comments", "-moderator", "-panelist"])
            .populate("createdBy");
        return res.status(200).send({ message: 'Query created successfully', data: query });
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.post('/query/list/public', async (req, res) => {
    const { page, limit, categories, statuses, search } = req.body;
    try {
        let queries = await getQueries(page, limit, categories, statuses, search);
        return res.status(200).send(queries);
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.post('/query/list', auth, async (req, res) => {
    const { page, limit, categories, statuses, search } = req.body;
    try {
        const { _id: userId } = req.session;
        let queries = await getQueries(page, limit, categories, statuses, search, userId);
        return res.status(200).send(queries);
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.get('/query/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const query = await Query.findById(id)
            .populate(populateQuery);
        return res.status(200).send({ data: query });
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.post('/query/assign', auth, async (req, res) => {
    const { id, panelist } = req.body;
    const { _id: moderator } = req.session;
    try {
        let existingQuery = await Query.findById(id);
        if (existingQuery.status !== 'opened') {
            throw 'Query is not opened to assign';
        }

        const query = await Query
            .findByIdAndUpdate(id, { moderator, panelist, status: 'assigned' }, { new: true })
            .populate(populateQuery);;

        return res.status(200).send({ data: query, message: 'Query assigned successfully' });
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.post('/query/answer', auth, async (req, res) => {
    const { id, answer } = req.body;
    const { _id: panelist } = req.session;
    try {
        const query = await postComment(id, answer, panelist);
        return res.status(200).send({ data: query, message: 'Query answered successfully' });
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

router.post('/query/answer/public', async (req, res) => {
    const { id, answer } = req.body;
    try {
        const query = await postComment(id, answer);
        return res.status(200).send({ data: query, message: 'Query answered successfully' });
    } catch (err) {
        return res.status(400).send({ error: { message: err.message ?? err } });
    }
});

const postComment = async (id, answer, authorId) => {
    var objc = { detail: answer };
    if (authorId) {
        objc.createdBy = authorId;
    }
    const comment = await Comment.create(objc);
    const query = await Query.findById(id);
    query.comments.push(comment._id);
    query.status = "answered";
    await query.save();

    const popQuery = await Query.findById(id).populate(populateQuery);
    return popQuery;
}

const getQueries = async (page, limit, categories, statuses, search, userId) => {
    var query = {};
    if (categories && categories.length > 0) { query.category = { $in: categories }; }
    if (statuses && statuses.length > 0) { query.status = { $in: statuses }; }
    if (search && search.length > 0) {
        // search by author's email
        let users = await User.find({
            email: { $regex: search, $options: "i" }
        });
        let authorIds = users.map(user => user._id);

        query.$or = [
            { createdBy: { $in: authorIds } },
            { title: { $regex: search, $options: "i" } },
            { description: { $regex: search, $options: "i" } }
        ];
    }
    if (userId) {
        let user = await User.findById(userId);
        if (!user) {
            throw "User not found";
        }
        if (user.role === "normal") {
            query.$or = [{ createdBy: userId }, { isPrivate: false }];
        }
        if (user.role === "panelist") {
            query.$or = [{ panelist: userId }];
        }
    } else {
        query.isPrivate = false;
    }
    logger.info(query);
    if (page && limit) {
        const queries = await Query.find(query)
            .skip((page - 1) * limit)
            .limit(limit)
            .select(["-comments", "-moderator", "-panelist"])
            .populate("createdBy");
        const total = await Query.countDocuments(query);

        return {
            data: queries,
            metadata: { page, limit, total },
        };
    }
    const queries = await Query
        .find(query)
        .select(["-comments", "-moderator", "-panelist"])
        .populate("createdBy");
    return { data: queries };
}

module.exports = router;