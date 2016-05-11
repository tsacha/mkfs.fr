%global commit 963c046c19b5d7019c607a8b648cae7b53d93ce2
%global shortcommit %(c=%{commit}; echo ${c:0:7})

Name:           dovecot-antispam
Version:        2.0
Release:        2%{?dist}
Summary:        The dovecot antispam plugin

Group:          System Environment/Libraries
License:        GPLv2
URL:            http://johannes.sipsolutions.net/Projects/%{name}
Source0:        http://git.sipsolutions.net/?p=%{name}.git;a=snapshot;h=%{shortcommit};sf=tgz#/%{name}-%{shortcommit}.tar.gz
# These patches have already been merged upstream
# Patch0:         %{name}-2.0-dovecot-2.1-compat.patch
# Patch1:         %{name}-2.0-remove-dict-code.patch
# Patch2:         %{name}-2.0-dovecot-2.2-compat.patch
# Patch3:         %{name}-2.0-add-patch-version-checks.patch
# Patch4:         %{name}-2.0-t_push-compat.patch

Requires:       dovecot
BuildRequires:  dovecot-devel

%description
The dovecot antispam plugin watches a defined spam folder (defaults to "SPAM").
It works together with a spam system that classifies each message as it is
delivered. When the message is classified as spam, it shall be delivered to the
spam folder, otherwise via the regular filtering file the user may have
(maildrop, sieve, ...). Now the user has everything classified as spam in the
special spam folder, everything else where it should be sorted to.

This is not enough because our spam scanner needs training. We'll occasionally
have false positives and false negatives. Now this is the point where the
dovecot antispam plugin comes into play. Instead of moving mail into special
folders or forwarding them to special mail addresses for retraining, the plugin
offers two actions for the user: 

  1. moving mail out of the SPAM folder and 
  2. moving mail into the SPAM folder. 

The dovecot plugin watches these actions (and additionally prohibits APPENDs to
the SPAM folder, more for technical reasons than others) and tells the spam
classifier that it made an error and needs to re-classify the message (as
spam/not spam depending on which way it was moved.) 

%prep
%setup -qn %{name}-%{shortcommit}

%build
CFLAGS="${CFLAGS:-%optflags}" make %{?_smp_mflags}

%install
install -d %{buildroot}%{_libdir}/dovecot
make %{?_smp_mflags} install DESTDIR=%{buildroot} moduledir=%{_libdir}/dovecot INSTALLDIR=%{_libdir}/dovecot
install -m0644 -p -D antispam.7 %{buildroot}%{_mandir}/man7/antispam.7

%files
%doc NOTES README
%license COPYING
%{_libdir}/dovecot/lib90_antispam_plugin.so
%{_mandir}/man7/antispam.7.gz

%changelog
* Mon Oct 26 2015 Scott K Logan <logans@cottsay.net> - 2.0-1
- Initial package
