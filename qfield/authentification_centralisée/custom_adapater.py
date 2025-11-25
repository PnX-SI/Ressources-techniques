
from django.core.exceptions import ObjectDoesNotExist, MultipleObjectsReturned, ValidationError

from qfieldcloud.core.models import Organization, OrganizationMember
from qfiedcould.core.adapters import SocialAccountAdapter

class MyCustomSocialAdapter(SocialAccountAdapter):
    """
    Adapateur customisé permettant d'ajouter un utilisateur au bon organisme en se basant son email
    """
    # NOTE : ce mécanisme ne gère pas le fait d'associer un utilisateur comme membre "staff"
    # Etre membre "staff" est necessaire pour se connecter à l'admin. Les administrateurs pourront à la main
    # ajouter quels utilisateurs sont "admin"
    def _set_organization(self, user)-> None:
        if user.email is None:
            raise ValidationError("The user has no email, cannot do organization mappping")
        # work only with Pnx adress, not OFB
        user_org_email = user.email.split("@")[1].split("-")[0]
        try:
            organization = Organization.objects.get(username__icontains=user_org_email)
        except ObjectDoesNotExist:
            raise ValidationError(
                "No organization with this email address"
            )
        except MultipleObjectsReturned:
            raise ValidationError(
                f"""Multiple organization found with this email address"
                "Please check your organisations. Email address was {user.email} """
            )
        org_member = OrganizationMember(
            organization=organization,
            member=user
        )
        org_member.save()
        organization.members.add(org_member)

    
    def save_user(self, request, sociallogin, form=None):
        user = super().save_user(request, sociallogin, form)
        self._set_organization(user)
        return user