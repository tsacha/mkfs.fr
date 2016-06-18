https://github.com/tsacha/s.tremoureux.fr.git:
  git.latest:
    - target: /opt/s.tremoureux.fr
    - watch_in:
      - exec: generate blog

backend configuration:
  file.managed:
    - name: /etc/nginx/conf.d/blog.conf
    - require:
      - pkg: nginx
    - watch_in:
      - service: start nginx
    - source: 'salt://st/blog.conf'

ruby.packages:
  pkg.installed:
    - pkgs:
      - rubygems
      - ruby-devel
      - ImageMagick
gems:
  gem.installed:
    - names:
      - jekyll
      - i18n
      - mini_magick
      - fastimage
      - redcarpet
      - pygments.rb
      - bigdecimal
      - json
    - require:
      - pkg: ruby.packages

generate blog:
  cmd.wait:
    - name: /usr/local/bin/jekyll build
    - cwd: /opt/s.tremoureux.fr
    - require:
      - gem: gems