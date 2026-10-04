from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, OTPCode, DealerProfile


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ('phone', 'full_name', 'role', 'phone_verified', 'region', 'is_active')
    list_filter = ('role', 'phone_verified', 'is_active')
    search_fields = ('phone', 'full_name')
    ordering = ('-date_joined',)
    fieldsets = (
        (None, {'fields': ('phone', 'password')}),
        ('Info', {'fields': ('full_name', 'email', 'role', 'region', 'mining_site', 'phone_verified')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    )
    add_fieldsets = (
        (None, {'classes': ('wide',), 'fields': ('phone', 'password1', 'password2', 'role')}),
    )


@admin.register(OTPCode)
class OTPCodeAdmin(admin.ModelAdmin):
    list_display = ('phone', 'code', 'created_at', 'expires_at', 'attempts', 'is_used')


@admin.register(DealerProfile)
class DealerProfileAdmin(admin.ModelAdmin):
    list_display = ('business_name', 'user', 'verification_status', 'license_number', 'created_at')
    list_filter = ('verification_status',)
    actions = ['approve_dealers']

    @admin.action(description='Approve selected dealers')
    def approve_dealers(self, request, queryset):
        from django.utils import timezone
        queryset.update(verification_status='verified', verified_at=timezone.now())
