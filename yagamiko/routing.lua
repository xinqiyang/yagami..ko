local router = require('yagami.router')
router.setup()

---------------------------------------------------------------------

--test map
map('^/test', 'test.test')

map('^/hello%?name=(.*)',           'test.hello')
map('^/longtext',                   'test.longtext')
map('^/ltp',                        'test.ltp')
map('^/ip',                         'ip.bootstrap')

-- timeline 
map('^/timeline',                      'timeline.bootstrap')

-- business
map('^/user',                      'user.bootstrap')

map('^/goods',                      'goods.bootstrap')
map('^/brand',                      'brand.bootstrap')
map('^/comment',					'comment.bootstrap')
map('^/notice',						'notice.bootstrap')

-- common 
map('^/id',                         'id.bootstrap')
map('^/version',                         'version.bootstrap')

-- image/file/audio storage
map('^/upload', 					'storage.savetoweedfs')

-- save to hbase or hadoop
map('^/service/soundget','sound.soundget')
map('^/service/soundmake','sound.soundmake')

---------------------------------------------------------------------
-- business interface list start
map('^/1.0/version',                         'version.bootstrap')

-- timeline
map('^/1.0/statuses/mentions_timeline','statuses.mentions_timeline')
map('^/1.0/statuses/user_timeline','statuses.user_timeline')
map('^/1.0/statuses/home_timeline','statuses.home_timeline')
map('^/1.0/statuses/retweets_of_me','statuses.retweets_of_me')

--tweets
map('^/1.0/statuses/retweets','statuses.retweets') -- get return 100, post generate new 
map('^/1.0/statuses/show','statuses.show')
map('^/1.0/statuses/destroy','statuses.show')

map('^/1.0/statuses/update','statuses.update')
map('^/1.0/statuses/update_with_media','statuses.update_update_with_media')

map('^/1.0/statuses/retweeters/ids','statuses.retweeters')

--search
map('^/1.0/search/entity','search.entity')

--streaming
map('^/1.0/statuses/filter','statuses.filter')
map('^/1.0/statuses/sample','statuses.sample')
map('^/1.0/statuses/firehose','statuses.firehose') --

map('^/1.0/user','user.bootstrap')
map('^/1.0/site','site.bootstrap')

--direct messages
map('^/1.0/direct_messages','message.bootstrap')
map('^/1.0/direct_messages/sent','message.sent')
map('^/1.0/direct_messages/show','message.show')
map('^/1.0/direct_messages/destroy','message.destroy')
map('^/1.0/direct_messages/new','message.new')

--friends and followers
map('^/1.0/friendships/no_retweets/ids','friendships.no_retweets')
map('^/1.0/friends/ids','friends.getfriends')
map('^/1.0/friendships/lookup','friendships.lookup')
map('^/1.0/friendships/incoming','friendships.incoming')
map('^/1.0/friendships/outgoing','friendships.outgoing')
map('^/1.0/friendships/create','friendships.create')
map('^/1.0/friendships/destroy','friendships.destroy')
map('^/1.0/friendships/update','friendships.update')
map('^/1.0/friendships/show','friendships.show')
map('^/1.0/friendships/list','friendships.list')
map('^/1.0/followers/list','followers.list')
map('^/1.0/followers/ids','followers.getfollowers')



--users
map('^/1.0/account/signup','account.signup')
map('^/1.0/account/forgetpassword','account.forgetpassword')
map('^/1.0/account/settings','account.getaccount')
map('^/1.0/account/settings','account.postaccount')
map('^/1.0/account/verify_credentials','account.verify_credentials')
map('^/1.0/account/update_delivery_device','account.update_delivery_device')
map('^/1.0/account/update_profile','account.update_profile')
map('^/1.0/account/update_profile_background_image','account.update_profile_background_image')
map('^/1.0/account/update_profile_colors','account.update_profile_colors')
map('^/1.0/account/update_profile_image','account.update_profile_image')

map('^/1.0/blocks/list','blocks.list')
map('^/1.0/blocks/ids','blocks.ids')
map('^/1.0/blocks/create','blocks.create')
map('^/1.0/blocks/destroy','blocks.destroy')

map('^/1.0/users/lookup','users.lookup')
map('^/1.0/users/show','users.show')
map('^/1.0/users/search','users.search')
map('^/1.0/users/search','users.search')
map('^/1.0/users/contributees','users.contributees')
map('^/1.0/users/contributors','users.contributors')
map('^/1.0/users/profile_banner','users.profile_banner')

map('^/1.0/account/remove_profile_banner','account.remove_profile_banner')
map('^/1.0/account/update_profile_banner','account.update_profile_banner')



-- suggest user
map('^/1.0/users/suggestions/cached','suggestusers.suggestionscached')
map('^/1.0/users/suggestions','suggestusers.suggestions')

--favorites
map('^/1.0/favorites/list','favorites.list')
map('^/1.0/favorites/destroy','favorites.destroy')
map('^/1.0/favorites/create','favorites.create')

--lists
map('^/1.0/lists/list','lists.list')
map('^/1.0/lists/statuses','lists.statuses')
map('^/1.0/lists/members/destroy','lists.membersdestroy') -- post 
map('^/1.0/lists/memberships','lists.memberships')
map('^/1.0/lists/subscribers','lists.subscribers')
map('^/1.0/lists/subscribers/create','lists.subscriberscreate')
map('^/1.0/lists/subscribers/show','lists.subscribersshow')
map('^/1.0/lists/subscribers/destroy','lists.subscribersdestroy')
map('^/1.0/lists/members/create_all','lists.memberscreate_all')
map('^/1.0/lists/members/show','lists.membersshow')
map('^/1.0/lists/members','lists.members')
map('^/1.0/lists/members/create','lists.memberscreate')
map('^/1.0/lists/destroy','lists.destroy')
map('^/1.0/lists/update','lists.update')
map('^/1.0/lists/create','lists.create')
map('^/1.0/lists/show','lists.show')
map('^/1.0/lists/subscriptions','lists.subscriptions')
map('^/1.0/lists/members/destroy_all','lists.membersdestroy_all')
map('^/1.0/lists/ownerships','lists.ownerships')

--saved searches
map('^/1.0/saved_searches/list','saved_searches.list')
map('^/1.0/saved_searches/show','saved_searches.show')
map('^/1.0/saved_searches/create','saved_searches.create')
map('^/1.0/saved_searches/destroy','saved_searches.destroy')


--places & geo
map('^/1.0/geo/id','geo.id')
map('^/1.0/geo/reverse_geocode','geo,reverse_geocode')
map('^/1.0/geo/search','geo.search')
map('^/1.0/geo/similar_places','geo.similar_places')
map('^/1.0/geo/place','geo.place') --create a place



-- use a new instance to deploy the interface
-- image/file/audio storage
map('^/1.0/upload','storage.savetoweedfs')
-- large file save to hdfs 
map('^/1.0/storage','storage.savetohdfs')
-- large kv save to hbase
map('^/1.0/kvstorage','storage.savetohbase')


--trends
map('^/1.0/trends/place','trends.place')
map('^/1.0/trends/available','trends.available')
map('^/1.0/trends/closest','trends.closest')

--spam reporting
map('^/1.0/users/report_spam','users/report_spam') 

--oauth 
map('^/1.0/oauth/authenticate','oauth.authenticate') 
map('^/1.0/oauth/authorize','oauth.authorize') 
map('^/1.0/oauth/access_token','oauth.access_token') 
map('^/1.0/oauth/request_token','oauth.request_token') 
map('^/1.0/oauth2/token','oauth2.token') 
map('^/1.0/oauth2/invalidate_token','oauth2.invalidate_token') 


--help 


-- business interface list end
