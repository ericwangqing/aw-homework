Handlebars.registerHelper 'BP-Composite', (t1, t2)->
    r1 = Template[t1]!
    r2 = Template[t2]! 
    r1 + '\n' + r2
