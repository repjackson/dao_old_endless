Meteor.methods
    log_view: (doc_id)->
        Docs.update doc_id,
            $inc:views:1

    

    # import_tests: ->
    #     # myobject = HTTP.get(Meteor.absoluteUrl("/public/tests.json")).data;
    #     myjson = JSON.parse(Assets.getText("tests.json"));
    #     console.log myjson
    add_message: (body,classroom_id)->
        new_message_id = Docs.insert
            body: body
            model: 'message'
            classroom_id: classroom_id
            read_ids:[Meteor.userId()]
            tags: ['chat', 'message']

        chat_doc = Docs.findOne _id: classroom_id
        message_doc = Docs.findOne new_message_id
        message_author = Meteor.users.findOne message_doc.author_id

        # message_link = "https://www.joyful-giver.com/chat"

        # this.unblock()

        # offline_ids = []
        # for participant_id in chat_doc.participant_ids
        #     user = Meteor.users.findOne participant_id
        #     if user.status.online is true
        #     else
        #         offline_ids.push user._id


        # for offline_id in offline_ids
        #     offline_user = Meteor.users.findOne offline_id

        #     Email.send
        #         to: " #{offline_user.profile.first_name} #{offline_user.profile.last_name} <#{offline_user.emails[0].address}>",
        #         from: "Joyful Giver Admin <no-reply@joyful-giver.com>",
        #         subject: "New Message from #{message_author.profile.first_name} #{message_author.profile.last_name}",
        #         html:
        #             "<h4>#{message_author.profile.first_name} just sent the following message while you were offline: </h4>
        #             #{body} <br><br>

        #             Click <a href=#{message_link}> here to view.</a><br><br>
        #             You can unsubscribe from this chat in the Actions panel.
        #             "

                # html:
                #     "<h4>#{message_author.profile.first_name} just sent the following message: </h4>
                #     #{text} <br>
                #     In chat with tags: #{chat_doc.tags}. \n
                #     In chat with description: #{chat_doc.description}. \n
                #     \n
                #     Click <a href="/view/#{_id}"
                # "
        # return new_message_id


    add_user: (username)->
        options = {}
        options.username = username
        options.levels = ['explorer']

        res= Accounts.createUser options
        if res
            return res
        else
            Throw.new Meteor.Error 'err creating user'


    change_username:  (user_id, new_username) ->
        user = Meteor.users.findOne user_id
        Accounts.setUsername(user._id, new_username)
        return "Updated Username to #{new_username}."


    add_email: (user_id, new_email) ->
        Accounts.addEmail(user_id, new_email);
        Accounts.sendVerificationEmail(user_id, new_email)
        return "updated Email to #{new_email}"

    remove_email: (user_id, email)->
        # user = Meteor.users.findOne username:username
        Accounts.removeEmail user_id, email


    verify_email: (user_id, email)->
        user = Meteor.users.findOne user_id
        console.log 'sending verification', user.username
        Accounts.sendVerificationEmail(user_id, email)

    validate_email: (email) ->
        re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
        test_result = re.test String(email)
        console.log email
        console.log test_result
        test_result

    notify_message: (message_id)->
        message = Docs.findOne message_id
        if message
            to_user = Meteor.users.findOne message.to_user_id
    
            message_link = "https://www.oneriverside.app/user/#{to_user.username}/messages"
    
        	Email.send({
                to:["<#{to_user.emails[0].address}>"]
                from:"relay@dao.af"
                subject:"One message from #{message._author_username}"
                html: "<h3> #{message._author_username} sent you the message:</h3>"+"<h2> #{message.body}.</h2>"+
                    "<br><h4>view your messages here:<a href=#{message_link}>#{message_link}</a>.</h4>"
            })

    checkout_students: ()->
        now = Date.now()
        # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()
        checkedin_sessions = Docs.find(
            model:'healthclub_session',
            active:true
            garden_key:$ne:true
            ).fetch()


        for session in checkedin_sessions
            # checkedin_doc =
            #     Docs.findOne
            #         user_id:student._id
            #         model:'healthclub_checkin'
            #         active:true
            diff = now-session._timestamp
            minute_difference = diff/1000/60
            if minute_difference>60
                # Meteor.users.update(student._id,{$set:healthclub_checkedin:false})
                Docs.update session._id,
                    $set:
                        active:false
                        logout_timestamp:Date.now()
                # checkedin_students = Meteor.users.find(healthclub_checkedin:true).fetch()



    lookup_user: (username_query, role_filter)->
        if role_filter
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                roles:$in:[role_filter]
                },{
                    limit:10
                    fields:
                        _id:1
                        username:1
                        profile_image_id:1
                    }).fetch()
        else
            Meteor.users.find({
                username: {$regex:"#{username_query}", $options: 'i'}
                },{
                    fields:
                        _id:1
                        username:1
                        profile_image_id:1
                    limit:10
                    }).fetch()
    # lookup_user: (username_query, role_filter)->
    #     if role_filter
    #         Meteor.users.find({
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             roles:$in:[role_filter]
    #             },{limit:10}).fetch()
    #     else
    #         Meteor.users.find({
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             },{limit:10}).fetch()


    lookup_doc: (guest_name, model_filter)->
        Docs.find({
            model:model_filter
            guest_name: {$regex:"#{guest_name}", $options: 'i'}
            },{limit:10}).fetch()


    lookup_earn_list: (title)->
        Docs.find({
            model:'earn_list'
            title: {$regex:"#{title}", $options: 'i'}
            }).fetch()

    # lookup_username: (username_query)->
    #     found_users =
    #         Docs.find({
    #             model:'person'
    #             username: {$regex:"#{username_query}", $options: 'i'}
    #             }).fetch()
    #     found_users

    # lookup_first_name: (first_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             first_name: {$regex:"#{first_name}", $options: 'i'}
    #             }).fetch()
    #     found_people
    #
    # lookup_last_name: (last_name)->
    #     found_people =
    #         Docs.find({
    #             model:'person'
    #             last_name: {$regex:"#{last_name}", $options: 'i'}
    #             }).fetch()
    #     found_people


    set_password: (user_id, new_password)->
        Accounts.setPassword(user_id, new_password)


    keys: (specific_key)->
        start = Date.now()

        if specific_key
            cursor = Docs.find({
                "#{specific_key}":$exists:true
                _keys:$exists:false
                }, { fields:{_id:1} })
        else
            cursor = Docs.find({
                _keys:$exists:false
            }, { fields:{_id:1} })

        found = cursor.count()

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id

        stop = Date.now()

        diff = stop - start

    key: (doc_id)->
        doc = Docs.findOne doc_id
        keys = _.keys doc

        light_fields = _.reject( keys, (key)-> key.startsWith '_' )

        Docs.update doc._id,
            $set:_keys:light_fields


    global_remove: (keyname)->
        result = Docs.update({"#{keyname}":$exists:true}, {
            $unset:
                "#{keyname}": 1
                "_#{keyname}": 1
            $pull:_keys:keyname
            }, {multi:true})


    count_key: (key)->
        count = Docs.find({"#{key}":$exists:true}).count()




    slugify: (doc_id)->
        doc = Docs.findOne doc_id
        slug = doc.title.toString().toLowerCase().replace(/\s+/g, '_').replace(/[^\w\-]+/g, '').replace(/\-\-+/g, '_').replace(/^-+/, '').replace(/-+$/,'')
        return slug
        # # Docs.update { _id:doc_id, fields:field_object },
        # Docs.update { _id:doc_id, fields:field_object },
        #     { $set: "fields.$.slug": slug }


    rename: (old, newk)->
        old_count = Docs.find({"#{old}":$exists:true}).count()
        new_count = Docs.find({"#{newk}":$exists:true}).count()
        result = Docs.update({"#{old}":$exists:true}, {$rename:"#{old}":"#{newk}"}, {multi:true})
        result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cursor.fetch()
            Meteor.call 'key', doc._id


    add_seller_username: ->
        cur = 
            Docs.find(
                seller_id:$exists:true
                seller_username:$exists:false
            )
        console.log cur.count()
        # old_count = Docs.find({"#{old}":$exists:true}).count()
        # new_count = Docs.find({"#{newk}":$exists:true}).count()
        # result = Docs.update({recipient_id:$exists:true}, {$rename:"recipient_id":"seller_id"}, {multi:true})
        for doc in cur.fetch()
            seller = 
                Meteor.users.findOne doc.seller_id
            if seller
                Docs.update doc._id,
                    $set:seller_username:seller.username
                # console.log seller
    update_debits: (old, newk)->
        cur = 
            Docs.find(
                model:'debit'
                # recipient_id:$exists:true
                # buyer_id:$exists:false
                amount:$exists:true
            )
        console.log cur.count()
        # old_count = Docs.find({"#{old}":$exists:true}).count()
        # new_count = Docs.find({"#{newk}":$exists:true}).count()
        # result = Docs.update({buyer_id:$exists:false}, {$rename:"recipient_id":"seller_id"}, {multi:true})
        # result = Docs.update({recipient_id:$exists:true}, {$rename:"recipient_id":"seller_id"})
        # result2 = Docs.update({"#{old}":$exists:true}, {$rename:"_#{old}":"_#{newk}"}, {multi:true})

        # > Docs.update({doc_sentiment_score:{$exists:true}},{$rename:{doc_sentiment_score:"sentiment_score"}},{multi:true})
        # cursor = Docs.find({newk:$exists:true}, { fields:_id:1 })

        for doc in cur.fetch()
            Docs.update doc._id,
                $rename:
                    amount:"price"

        # for doc in cur.fetch()
        #     buyer = 
        #         Meteor.users.findOne doc._author_id
        #     if buyer
        #         Docs.update doc._id,
        #             $set:
        #                 buyer_id:buyer._id
        #                 buyer_username:buyer.username




    send_enrollment_email: (user_id, email)->
        user = Meteor.users.findOne(user_id)
        console.log 'sending enrollment email to username', user.username
        Accounts.sendEnrollmentEmail(user_id)

    calc_user_tags: (user_id)->
        debit_tags = Meteor.call 'omega', user_id, 'debit'
        # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
        # console.log res
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                debit_tags:debit_tags

        credit_tags = Meteor.call 'omega', user_id, 'credit'
        # console.log res
        # console.log 'res from async agg'
        Meteor.users.update user_id, 
            $set:
                credit_tags:credit_tags


    omega: (user_id, direction)->
        user = Meteor.users.findOne user_id
        options = {
            explain:false
            allowDiskUse:true
        }
        match = {}
        match.model = 'debit'
        if direction is 'debit'
            match._author_id = user_id
        if direction is 'credit'
            match.recipient_id = user_id

        console.log 'found debits', Docs.find(match).count()
        # if omega.selected_tags.length > 0
        #     limit = 42
        # else
        # limit = 10
        # console.log 'omega_match', match
        # { $match: tags:$all: omega.selected_tags }
        pipe =  [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            # { $match: _id: $nin: omega.selected_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, title: '$_id', count: 1 }
        ]

        if pipe
            agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
                # printed = console.log(agg.toArray())
                # console.log(agg.toArray())
                # omega = Docs.findOne model:'omega_session'
                # Docs.update omega._id,
                #     $set:
                #         agg:agg.toArray()
        else
            return null