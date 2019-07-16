<?php
$db = new PDO('mysql:host=localhost', 'root', null);
?>
<!doctype html>
<html lang=en>
<head>
    <meta charset=utf-8>
    <title>Hello World from PHP 5 on Docker</title>
    <style>
        body { font-family: sans-serif; }
        pre {
            font-family: monospace;
            padding: 16px;
            overflow: auto;
            font-size: 85%;
            line-height: 1.45;
            background-color: #f7f7f7;
            border-radius: 3px;
            word-wrap: normal;
        }
        .container {
            max-width: 1024px;
            width: 100%;
            margin: 0 auto;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <img src="https://cdn.rawgit.com/mattrayner/docker-lamp/831976c022782e592b7e2758464b2a9efe3da042/docs/logo.svg" alt="Docker LAMP logo" />
        </header>
        <article>
            <p>
                Hello World! Documentation can be <a href="https://github.com/jakejarvis/docker-lamp-php5" target="_blank">found on GitHub</a>.
            </p>
        </article>
        <section>
            <pre>
OS: <?php echo php_uname('s'); ?><br/>
Apache: <?php echo apache_get_version(); ?><br/>
MySQL Version: <?php echo $db->getAttribute( PDO::ATTR_SERVER_VERSION ); ?><br/>
PHP Version: <?php echo phpversion(); ?><br/>
phpMyAdmin Version: <?php echo getenv('PHPMYADMIN_VERSION'); ?>
            </pre>
        </section>
    </div>
</body>
</html>