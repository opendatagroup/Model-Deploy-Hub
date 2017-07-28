# our user list
c.Authenticator.whitelist = [
    'mahowald-odg',
    'georgek42',
    'jackmoore5021',
    'spederson-odg',
    'savsec',
]

# ellisonbg and willingc have access to a shared server:

c.JupyterHub.load_groups = {
    'shared': [
        'mahowald-odg',
        'georgek42',
        'jackmoore5021',
        'spederson-odg',
        'savsec',
    ]
}

# start the notebook server as a service
c.JupyterHub.services = [
    {
        'name': 'shared-notebook',
        'url': 'http://127.0.0.1:9999',
        'api_token': '46668c09a8569a8ba280023a62a9d8bf3be9d2ae2700a76766ef701a507c227d',
    }
]
