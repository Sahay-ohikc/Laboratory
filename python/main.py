def checker(req):
    import requests
    import os
    respo = requests.get('http://' + os.getenv('IPADDRESSES'))
    #if counter >= 3: send email
    if respo.status_code >= 400:
      print('GOING DOWN!!!')
    else: 
      print('I am fine')
    return 'Finished, {}'.format(respo.status_code)
