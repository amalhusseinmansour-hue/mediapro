#!/bin/bash
# Deploy Flutter Web to webapp directory

cd /home/u126213189/domains/mediaprosocial.io/public_html

# Backup current webapp if exists
if [ -d "webapp" ]; then
    echo "Backing up current webapp..."
    mv webapp webapp_backup_$(date +%Y%m%d_%H%M%S)
fi

# Create new webapp directory
mkdir -p webapp
cd webapp

# Extract Flutter Web files
echo "Extracting Flutter Web build..."
tar -xzf /home/u126213189/webapp-flutter.tar.gz

# Create .htaccess for proper routing
echo "Creating .htaccess..."
cat > .htaccess << 'HTACCESS'
DirectoryIndex index.html

<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /webapp/

# Don't rewrite files or directories
RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]

# Rewrite everything else to index.html
RewriteRule ^ index.html [L]
</IfModule>

# Enable CORS for assets
<FilesMatch "\.(ttf|otf|eot|woff|woff2|js|css|json)$">
    <IfModule mod_headers.c>
        Header set Access-Control-Allow-Origin "*"
    </IfModule>
</FilesMatch>

# Cache static assets
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/x-icon "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/svg+xml "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType application/x-javascript "access plus 1 month"
</IfModule>

Options -Indexes
HTACCESS

# Set proper permissions
chmod 755 .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;

echo "Deployment complete!"
echo "Flutter Web app is now available at: https://mediaprosocial.io/webapp/"
ls -lah
