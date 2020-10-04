# tsqp-gebk-xhpz-eobp-agle
Docs.allow
    insert: (user_id, doc) ->
        false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        # else
        #     user_id is doc._author_id
    update: (user_id, doc) ->
        # user = Meteor.users.findOne user_id
        # console.log user_id
        # console.log doc._author_id
        false
        # if user_id is doc._author_id
        # else if user.roles and 'admin' in user.roles
        #     true
    remove: (user_id, doc) ->
        false
        # user = Meteor.users.findOne user_id
        # if user.roles and 'admin' in user.roles
        #     true
        # else
        #     user_id is doc._author_id



Meteor.publish 'doc_by_title', (title)->
    # console.log title
    Docs.find
        title:title
        model:'wikipedia'


Meteor.publish 'docs', (
    selected_tags
    toggle
    query=''
    selected_domains
    selected_authors
    )->
    match = {}
    match.model = $in:['reddit']
    # match.model = 'wikipedia'
    if selected_domains.length > 0 
        match.domain = $all: selected_domains
    if selected_authors.length > 0 
        match.author = $all: selected_authors
    
    # match.model = 'post'
    # if Meteor.user()
    #     match.downvoter_ids = $nin:[Meteor.userId()]
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0
        match.tags = $all:selected_tags
        # console.log match
        Docs.find match,
            limit:3
            sort:
                # points:-1
                ups:-1
                # _timestamp:-1
                # views:-1
    else
        match.tags = $in:['dao']
        # console.log match
        Docs.find match,
            limit:3
            sort:
                _timestamp:-1
                # points:-1
                ups:-1
                    
                    
Meteor.publish 'dtags', (
    selected_tags
    toggle
    query=''
    selected_domains
    selected_authors
    )->
    self = @
    match = {}
    # match.model = $in:['post','wikipedia','reddit','porn']
    # match.model = $in:['reddit']
    match.model = $in:['reddit','wikipedia']
    # match.model = 'wikipedia'
    
    # if query.length > 1
    #     match.title = {$regex:"#{query}", $options: 'i'}
    if selected_tags.length > 0 
        match.tags = $all: selected_tags
    else
        match.tags = $in:['dao']
    if selected_domains.length > 0 
        match.domain = $all: selected_domains
    if selected_authors.length > 0 
        match.author = $all: selected_authors

    count = Docs.find(match).count()
    console.log count

    if query.length > 1
        console.log 'searching query', query
        # #     # match.tags = {$regex:"#{query}", $options: 'i'}
        # #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
        # #
        terms = Docs.find({
            # title: {$regex:"#{query}"}
            model:'wikipedia'            
            title: {$regex:"#{query}", $options: 'i'}
        },
            # sort:
            #     count: -1
            limit: 5
        )
    else
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: selected_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud: ', tag_cloud
        # console.log 'tag match', match
        tag_cloud.forEach (tag, i) ->
            self.added 'tag_results', Random.id(),
                name: tag.name
                count: tag.count
                index: i
        
        
        domain_cloud = Docs.aggregate [
            { $match: match }
            { $project: "domain": 1 }
            # { $unwind: "$domain" }
            { $group: _id: "$domain", count: $sum: 1 }
            { $match: _id: $nin: selected_domains }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud: ', domain_cloud
        # console.log 'domain match', match
        domain_cloud.forEach (domain, i) ->
            self.added 'domain_results', Random.id(),
                name: domain.name
                count: domain.count
                index: i
       
        author_cloud = Docs.aggregate [
            { $match: match }
            { $project: "author": 1 }
            # { $unwind: "$author" }
            { $group: _id: "$author", count: $sum: 1 }
            { $match: _id: $nin: selected_authors }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        # console.log 'cloud: ', author_cloud
        # console.log 'author match', match
        author_cloud.forEach (author, i) ->
            self.added 'author_results', Random.id(),
                name: author.name
                count: author.count
                index: i
       
    self.ready()
                    
                    