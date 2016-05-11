Name: openldap-sha2
Version: 2.4.43
Release: 4%{?dist}
Summary: OpenLDAP SHA2 module
Group: System Environment/Daemons
License: OpenLDAP
URL: http://www.openldap.org/

Source0: ftp://ftp.OpenLDAP.org/pub/OpenLDAP/openldap-release/openldap-%{version}.tgz

BuildRequires: cyrus-sasl-devel, nss-devel, krb5-devel, tcp_wrappers-devel, unixODBC-devel
BuildRequires: glibc-devel, libtool, libtool-ltdl-devel, groff, perl, perl-devel, perl(ExtUtils::Embed)
BuildRequires: openssl-devel
BuildRequires: libdb-devel
BuildRequires: cracklib-devel
Requires: nss-tools

%description
SHA2 module for OpenLDAP.

%prep
%setup -q -c -a 0
pushd openldap-%{version}
%configure

%build
pushd openldap-%{version}/
make %{_smp_mflags}
popd

pushd openldap-%{version}/contrib/slapd-modules/passwd/sha2/
make %{_smp_mflags}
popd

%install
mkdir -p %{buildroot}%{_libdir}/openldap/
pushd openldap-%{version}/contrib/slapd-modules/passwd/sha2/
cp .libs/pw-sha2.so %{buildroot}%{_libdir}/openldap/
pushd %{buildroot}%{_libdir}/openldap/
ln -s pw-sha2.so pw-sha2.so.0
ln -s pw-sha2.so pw-sha2.so.0.0.0
popd

%files
%{_libdir}/openldap/pw-sha2.so
%{_libdir}/openldap/pw-sha2.so.0
%{_libdir}/openldap/pw-sha2.so.0.0.0

%changelog
* Wed Apr 21 2016 Sacha Trémoureux <sacha@tremoureux.fr> 2.4.43-4
- Initial package for SHA2 module
